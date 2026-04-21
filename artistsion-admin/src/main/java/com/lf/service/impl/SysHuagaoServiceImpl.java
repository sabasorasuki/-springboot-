package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.common.constants.TagConstants;
import com.lf.common.constants.TagSourceConstants;
import com.lf.common.exception.BusinessException;
import com.lf.common.request.SysHuagaoPublishRequest;
import com.lf.common.utils.TagNormalizationUtil;
import com.lf.common.utils.TagSensitiveWordUtil;
import com.lf.dao.SysFenleiMapper;
import com.lf.dao.SysHuagaoMapper;
import com.lf.dao.SysHuagaoTagMapper;
import com.lf.dao.SysTagAliasMapper;
import com.lf.dao.SysTagMapper;
import com.lf.entity.SysFenlei;
import com.lf.entity.SysHuagao;
import com.lf.entity.SysHuagaoTag;
import com.lf.entity.SysTag;
import com.lf.entity.SysTagAlias;
import com.lf.entity.User;
import com.lf.service.SysHuagaoService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class SysHuagaoServiceImpl extends ServiceImpl<SysHuagaoMapper, SysHuagao> implements SysHuagaoService {

    @Resource
    private SysTagMapper sysTagMapper;

    @Resource
    private SysTagAliasMapper sysTagAliasMapper;

    @Resource
    private SysHuagaoTagMapper sysHuagaoTagMapper;

    @Resource
    private SysFenleiMapper sysFenleiMapper;

    @Override
    public SysHuagao getDetailById(Long id) {
        if (id == null) {
            throw new BusinessException(20001, "画稿ID不能为空");
        }
        SysHuagao huagao = getById(id);
        if (huagao == null) {
            throw new BusinessException(20001, "画稿不存在");
        }
        fillTagInfo(huagao);
        return huagao;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SysHuagao savePublishedHuagao(SysHuagaoPublishRequest request, User loginUser) {
        if (loginUser == null || loginUser.getId() == null) {
            throw new BusinessException(20003, "未登录或登录已失效");
        }
        if (request == null) {
            throw new BusinessException(20001, "提交内容不能为空");
        }

        validateHuagaoRequest(request);
        validateCategory(request.getFenlei());

        List<SysTag> systemTags = resolveSystemTags(request.getSystemTagIds());
        List<SysTag> freeTags = resolveFreeTags(request.getFreeTagNames());
        Map<Long, String> relationSources = mergeTagSources(systemTags, freeTags);

        SysHuagao target;
        if (request.getId() == null) {
            target = new SysHuagao();
            target.setShangjiaids(String.valueOf(loginUser.getId()));
            target.setType(StringUtils.hasText(request.getType()) ? request.getType() : "上架");
            target.setStatus(StringUtils.hasText(request.getStatus()) ? request.getStatus() : "审核成功");
            applyPublishFields(target, request);
            save(target);
        } else {
            target = getById(request.getId());
            if (target == null) {
                throw new BusinessException(20001, "画稿不存在");
            }
            if (!String.valueOf(loginUser.getId()).equals(target.getShangjiaids())) {
                throw new BusinessException(20001, "只能编辑自己的橱窗");
            }
            applyPublishFields(target, request);
            if (StringUtils.hasText(request.getType())) {
                target.setType(request.getType());
            }
            if (StringUtils.hasText(request.getStatus())) {
                target.setStatus(request.getStatus());
            }
            updateById(target);
        }

        syncHuagaoTags(target.getId(), relationSources);
        fillTagInfo(target);
        return target;
    }

    private void validateHuagaoRequest(SysHuagaoPublishRequest request) {
        if (!StringUtils.hasText(request.getName())) {
            throw new BusinessException(20001, "画稿名称不能为空");
        }
        if (request.getName().trim().length() > 255) {
            throw new BusinessException(20001, "画稿名称不能超过255个字符");
        }
        if (!StringUtils.hasText(request.getPhoto())) {
            throw new BusinessException(20001, "请先上传封面图");
        }
        if (!StringUtils.hasText(request.getFenlei())) {
            throw new BusinessException(20001, "请选择分类");
        }
        if (request.getPrice() == null) {
            throw new BusinessException(20001, "请填写价格");
        }
        if (request.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new BusinessException(20001, "价格不能小于0");
        }
        Integer zhekou = request.getZhekou() == null ? 0 : request.getZhekou();
        if (zhekou < 0) {
            throw new BusinessException(20001, "折扣不能小于0");
        }
        request.setZhekou(zhekou);
    }

    private void validateCategory(String fenlei) {
        LambdaQueryWrapper<SysFenlei> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysFenlei::getFenlei, fenlei)
                .eq(SysFenlei::getDeleted, 0)
                .eq(SysFenlei::getStatus, 1)
                .last("LIMIT 1");
        SysFenlei category = sysFenleiMapper.selectOne(wrapper);
        if (category == null) {
            throw new BusinessException(20001, "分类不存在或已禁用，请重新选择");
        }
    }

    private List<SysTag> resolveSystemTags(List<Long> systemTagIds) {
        if (systemTagIds == null || systemTagIds.isEmpty()) {
            throw new BusinessException(20001, "请至少选择3个系统标签");
        }

        List<Long> distinctIds = systemTagIds.stream()
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());

        if (distinctIds.size() < 3 || distinctIds.size() > 8) {
            throw new BusinessException(20001, "系统标签数量需控制在3到8个之间");
        }

        List<SysTag> tags = sysTagMapper.selectBatchIds(distinctIds);
        Map<Long, SysTag> tagMap = tags.stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toMap(SysTag::getId, item -> item));

        List<SysTag> orderedTags = new ArrayList<>();
        for (Long tagId : distinctIds) {
            SysTag tag = tagMap.get(tagId);
            if (tag == null || !Objects.equals(tag.getDeleted(), 0)) {
                throw new BusinessException(20001, "存在无效的系统标签，请刷新后重试");
            }
            if (!TagConstants.TYPE_SYSTEM.equals(tag.getTagType())) {
                throw new BusinessException(20001, "系统标签类型不合法");
            }
            if (!Objects.equals(tag.getStatus(), 1)) {
                throw new BusinessException(20001, "存在已禁用的系统标签，请重新选择");
            }
            orderedTags.add(tag);
        }
        return orderedTags;
    }

    private List<SysTag> resolveFreeTags(List<String> freeTagNames) {
        if (freeTagNames == null || freeTagNames.isEmpty()) {
            return Collections.emptyList();
        }

        Map<String, String> normalizedToDisplay = new LinkedHashMap<>();
        for (String rawName : freeTagNames) {
            String displayName = TagNormalizationUtil.sanitizeDisplayName(rawName);
            String normalizedName = TagNormalizationUtil.normalize(rawName);

            if (!StringUtils.hasText(displayName) || !StringUtils.hasText(normalizedName)) {
                continue;
            }
            if (displayName.length() < 2 || displayName.length() > 20) {
                throw new BusinessException(20001, "自由标签长度需控制在2到20个字符之间");
            }
            if (TagSensitiveWordUtil.containsSensitiveWord(normalizedName)) {
                throw new BusinessException(20001, "自由标签包含敏感词，请调整后重试");
            }
            normalizedToDisplay.putIfAbsent(normalizedName, displayName);
        }

        if (normalizedToDisplay.size() > 10) {
            throw new BusinessException(20001, "自由标签最多填写10个");
        }

        List<SysTag> resolvedTags = new ArrayList<>();
        for (Map.Entry<String, String> entry : normalizedToDisplay.entrySet()) {
            resolvedTags.add(resolveSingleFreeTag(entry.getKey(), entry.getValue()));
        }
        return resolvedTags;
    }

    private SysTag resolveSingleFreeTag(String normalizedName, String displayName) {
        LambdaQueryWrapper<SysTag> tagWrapper = new LambdaQueryWrapper<>();
        tagWrapper.eq(SysTag::getNormalizedName, normalizedName)
                .eq(SysTag::getDeleted, 0)
                .last("LIMIT 1");
        SysTag exactTag = sysTagMapper.selectOne(tagWrapper);
        if (exactTag != null) {
            return exactTag;
        }

        LambdaQueryWrapper<SysTagAlias> aliasWrapper = new LambdaQueryWrapper<>();
        aliasWrapper.eq(SysTagAlias::getNormalizedName, normalizedName)
                .last("LIMIT 1");
        SysTagAlias alias = sysTagAliasMapper.selectOne(aliasWrapper);
        if (alias != null) {
            SysTag aliasedTag = sysTagMapper.selectById(alias.getTagId());
            if (aliasedTag != null && Objects.equals(aliasedTag.getDeleted(), 0)) {
                return aliasedTag;
            }
        }

        SysTag freeTag = new SysTag();
        freeTag.setName(displayName);
        freeTag.setNormalizedName(normalizedName);
        freeTag.setTagType(TagConstants.TYPE_FREE);
        freeTag.setTagGroup(null);
        freeTag.setStatus(1);
        freeTag.setUseCount(0);
        freeTag.setDeleted(0);
        sysTagMapper.insert(freeTag);
        return freeTag;
    }

    private Map<Long, String> mergeTagSources(List<SysTag> systemTags, List<SysTag> freeTags) {
        Map<Long, String> relationSources = new LinkedHashMap<>();
        for (SysTag tag : systemTags) {
            relationSources.put(tag.getId(), TagSourceConstants.SYSTEM);
        }
        for (SysTag tag : freeTags) {
            relationSources.putIfAbsent(tag.getId(), TagSourceConstants.FREE);
        }
        return relationSources;
    }

    private void applyPublishFields(SysHuagao target, SysHuagaoPublishRequest request) {
        target.setName(request.getName().trim());
        target.setPhoto(request.getPhoto());
        target.setPrice(request.getPrice());
        target.setFenlei(request.getFenlei());
        target.setFujin(StringUtils.hasText(request.getFujin()) ? request.getFujin().trim() : "");
        target.setContent(StringUtils.hasText(request.getContent()) ? request.getContent() : "");
        target.setZhekou(request.getZhekou());
    }

    private void syncHuagaoTags(Long huagaoId, Map<Long, String> relationSources) {
        List<Long> existingTagIds = listHuagaoTagIds(huagaoId);

        LambdaQueryWrapper<SysHuagaoTag> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(SysHuagaoTag::getHuagaoId, huagaoId);
        sysHuagaoTagMapper.delete(deleteWrapper);

        if (!relationSources.isEmpty()) {
            for (Map.Entry<Long, String> entry : relationSources.entrySet()) {
                SysHuagaoTag relation = new SysHuagaoTag();
                relation.setHuagaoId(huagaoId);
                relation.setTagId(entry.getKey());
                relation.setTagSource(entry.getValue());
                sysHuagaoTagMapper.insert(relation);
            }
        }

        Set<Long> affectedTagIds = new LinkedHashSet<>(existingTagIds);
        affectedTagIds.addAll(relationSources.keySet());
        refreshTagUseCount(affectedTagIds);
    }

    private List<Long> listHuagaoTagIds(Long huagaoId) {
        LambdaQueryWrapper<SysHuagaoTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysHuagaoTag::getHuagaoId, huagaoId);
        List<SysHuagaoTag> relations = sysHuagaoTagMapper.selectList(wrapper);
        return relations.stream().map(SysHuagaoTag::getTagId).collect(Collectors.toList());
    }

    private void refreshTagUseCount(Collection<Long> tagIds) {
        if (tagIds == null || tagIds.isEmpty()) {
            return;
        }
        for (Long tagId : tagIds) {
            if (tagId == null) {
                continue;
            }
            LambdaQueryWrapper<SysHuagaoTag> countWrapper = new LambdaQueryWrapper<>();
            countWrapper.eq(SysHuagaoTag::getTagId, tagId);
            Long count = sysHuagaoTagMapper.selectCount(countWrapper);
            SysTag tag = sysTagMapper.selectById(tagId);
            if (tag != null && Objects.equals(tag.getDeleted(), 0)) {
                tag.setUseCount(count == null ? 0 : count.intValue());
                sysTagMapper.updateById(tag);
            }
        }
    }

    private void fillTagInfo(SysHuagao huagao) {
        if (huagao == null || huagao.getId() == null) {
            return;
        }

        LambdaQueryWrapper<SysHuagaoTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysHuagaoTag::getHuagaoId, huagao.getId())
                .orderByAsc(SysHuagaoTag::getId);
        List<SysHuagaoTag> relations = sysHuagaoTagMapper.selectList(wrapper);
        if (relations.isEmpty()) {
            huagao.setSystemTagIds(new ArrayList<>());
            huagao.setFreeTagNames(new ArrayList<>());
            huagao.setSystemTags(new ArrayList<>());
            return;
        }

        List<Long> tagIds = relations.stream()
                .map(SysHuagaoTag::getTagId)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
        List<SysTag> tags = sysTagMapper.selectBatchIds(tagIds);
        Map<Long, SysTag> tagMap = tags.stream()
                .filter(Objects::nonNull)
                .filter(tag -> Objects.equals(tag.getDeleted(), 0))
                .collect(Collectors.toMap(SysTag::getId, item -> item));

        List<Long> systemTagIds = new ArrayList<>();
        List<String> freeTagNames = new ArrayList<>();
        List<SysTag> systemTags = new ArrayList<>();
        for (SysHuagaoTag relation : relations) {
            SysTag tag = tagMap.get(relation.getTagId());
            if (tag == null) {
                continue;
            }
            if (TagSourceConstants.SYSTEM.equals(relation.getTagSource())) {
                systemTagIds.add(tag.getId());
                systemTags.add(tag);
            } else {
                freeTagNames.add(tag.getName());
            }
        }

        huagao.setSystemTagIds(systemTagIds);
        huagao.setFreeTagNames(freeTagNames);
        huagao.setSystemTags(systemTags);
    }
}
