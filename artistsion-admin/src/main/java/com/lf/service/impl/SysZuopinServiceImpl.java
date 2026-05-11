package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.common.constants.TagConstants;
import com.lf.common.constants.TagSourceConstants;
import com.lf.common.exception.BusinessException;
import com.lf.common.utils.TagNormalizationUtil;
import com.lf.common.utils.TagSensitiveWordUtil;
import com.lf.dao.SysHuagaoTagMapper;
import com.lf.dao.SysTagAliasMapper;
import com.lf.dao.SysTagMapper;
import com.lf.entity.SysZuopin;
import com.lf.dao.SysZuopinMapper;
import com.lf.dao.SysZuopinTagMapper;
import com.lf.entity.SysHuagaoTag;
import com.lf.entity.SysTag;
import com.lf.entity.SysTagAlias;
import com.lf.entity.SysZuopinTag;
import com.lf.service.SysZuopinService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
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

/**
 * <p>
 *  服务实现类
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
@Service
public class SysZuopinServiceImpl extends ServiceImpl<SysZuopinMapper, SysZuopin> implements SysZuopinService {

    @Resource
    private SysTagMapper sysTagMapper;

    @Resource
    private SysTagAliasMapper sysTagAliasMapper;

    @Resource
    private SysZuopinTagMapper sysZuopinTagMapper;

    @Resource
    private SysHuagaoTagMapper sysHuagaoTagMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveWithTags(SysZuopin zuopin) {
        boolean saved = save(zuopin);
        syncZuopinTags(zuopin.getId(), resolveFreeTags(zuopin.getFreeTagNames()));
        return saved;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateWithTags(SysZuopin zuopin) {
        boolean updated = updateById(zuopin);
        if (zuopin.getId() != null && zuopin.getFreeTagNames() != null) {
            syncZuopinTags(zuopin.getId(), resolveFreeTags(zuopin.getFreeTagNames()));
        }
        return updated;
    }

    @Override
    public SysZuopin getDetailById(Long id) {
        if (id == null) {
            throw new BusinessException(20001, "作品ID不能为空");
        }
        SysZuopin zuopin = getById(id);
        if (zuopin == null) {
            throw new BusinessException(20001, "作品不存在");
        }
        fillTagInfo(zuopin);
        return zuopin;
    }

    @Override
    public void fillTagInfo(List<SysZuopin> zuopinList) {
        if (zuopinList == null || zuopinList.isEmpty()) {
            return;
        }
        for (SysZuopin zuopin : zuopinList) {
            fillTagInfo(zuopin);
        }
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

    private void syncZuopinTags(Long zuopinId, List<SysTag> freeTags) {
        if (zuopinId == null) {
            return;
        }
        List<Long> existingTagIds = listZuopinTagIds(zuopinId);

        LambdaQueryWrapper<SysZuopinTag> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(SysZuopinTag::getZuopinId, zuopinId);
        sysZuopinTagMapper.delete(deleteWrapper);

        for (SysTag tag : freeTags) {
            SysZuopinTag relation = new SysZuopinTag();
            relation.setZuopinId(zuopinId);
            relation.setTagId(tag.getId());
            relation.setTagSource(TagSourceConstants.FREE);
            sysZuopinTagMapper.insert(relation);
        }

        Set<Long> affectedTagIds = new LinkedHashSet<>(existingTagIds);
        affectedTagIds.addAll(freeTags.stream().map(SysTag::getId).collect(Collectors.toList()));
        refreshTagUseCount(affectedTagIds);
    }

    private List<Long> listZuopinTagIds(Long zuopinId) {
        LambdaQueryWrapper<SysZuopinTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysZuopinTag::getZuopinId, zuopinId);
        List<SysZuopinTag> relations = sysZuopinTagMapper.selectList(wrapper);
        return relations.stream().map(SysZuopinTag::getTagId).collect(Collectors.toList());
    }

    private void refreshTagUseCount(Collection<Long> tagIds) {
        if (tagIds == null || tagIds.isEmpty()) {
            return;
        }
        for (Long tagId : tagIds) {
            if (tagId == null) {
                continue;
            }
            LambdaQueryWrapper<SysZuopinTag> zuopinCountWrapper = new LambdaQueryWrapper<>();
            zuopinCountWrapper.eq(SysZuopinTag::getTagId, tagId);
            Long zuopinCount = sysZuopinTagMapper.selectCount(zuopinCountWrapper);

            LambdaQueryWrapper<SysHuagaoTag> huagaoCountWrapper = new LambdaQueryWrapper<>();
            huagaoCountWrapper.eq(SysHuagaoTag::getTagId, tagId);
            Long huagaoCount = sysHuagaoTagMapper.selectCount(huagaoCountWrapper);

            SysTag tag = sysTagMapper.selectById(tagId);
            if (tag != null && Objects.equals(tag.getDeleted(), 0)) {
                tag.setUseCount((zuopinCount == null ? 0 : zuopinCount.intValue())
                        + (huagaoCount == null ? 0 : huagaoCount.intValue()));
                sysTagMapper.updateById(tag);
            }
        }
    }

    private void fillTagInfo(SysZuopin zuopin) {
        if (zuopin == null || zuopin.getId() == null) {
            return;
        }

        LambdaQueryWrapper<SysZuopinTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysZuopinTag::getZuopinId, zuopin.getId())
                .orderByAsc(SysZuopinTag::getId);
        List<SysZuopinTag> relations = sysZuopinTagMapper.selectList(wrapper);
        if (relations.isEmpty()) {
            zuopin.setFreeTagNames(new ArrayList<>());
            return;
        }

        List<Long> tagIds = relations.stream()
                .map(SysZuopinTag::getTagId)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
        List<SysTag> tags = sysTagMapper.selectBatchIds(tagIds);
        Map<Long, SysTag> tagMap = tags.stream()
                .filter(Objects::nonNull)
                .filter(tag -> Objects.equals(tag.getDeleted(), 0))
                .collect(Collectors.toMap(SysTag::getId, item -> item));

        List<String> freeTagNames = new ArrayList<>();
        for (SysZuopinTag relation : relations) {
            SysTag tag = tagMap.get(relation.getTagId());
            if (tag != null) {
                freeTagNames.add(tag.getName());
            }
        }
        zuopin.setFreeTagNames(freeTagNames);
    }
}
