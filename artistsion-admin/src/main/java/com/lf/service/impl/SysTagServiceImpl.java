package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.common.constants.TagConstants;
import com.lf.common.exception.BusinessException;
import com.lf.common.request.SysTagCreateRequest;
import com.lf.common.request.SysTagUpdateRequest;
import com.lf.common.utils.TagNormalizationUtil;
import com.lf.dao.SysTagAliasMapper;
import com.lf.dao.SysTagMapper;
import com.lf.entity.SysTag;
import com.lf.entity.SysTagAlias;
import com.lf.service.SysTagService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import javax.annotation.Resource;
import java.util.List;

@Service
public class SysTagServiceImpl extends ServiceImpl<SysTagMapper, SysTag> implements SysTagService {

    @Resource
    private SysTagAliasMapper sysTagAliasMapper;

    @Override
    public Page<SysTag> getPage(String name, String tagType, String tagGroup, Integer status, Long pageNo, Long pageSize) {
        LambdaQueryWrapper<SysTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysTag::getDeleted, 0)
                .like(StringUtils.hasText(name), SysTag::getName, name)
                .eq(StringUtils.hasText(tagType), SysTag::getTagType, tagType)
                .eq(StringUtils.hasText(tagGroup), SysTag::getTagGroup, tagGroup)
                .eq(status != null, SysTag::getStatus, status)
                .orderByAsc(SysTag::getId);

        Page<SysTag> page = new Page<>(pageNo, pageSize);
        page(page, wrapper);
        return page;
    }

    @Override
    public SysTag getActiveById(Long id) {
        if (id == null) {
            throw new BusinessException(20001, "标签ID不能为空");
        }
        LambdaQueryWrapper<SysTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysTag::getId, id)
                .eq(SysTag::getDeleted, 0)
                .last("LIMIT 1");
        SysTag tag = getOne(wrapper, false);
        if (tag == null) {
            throw new BusinessException(20001, "标签不存在");
        }
        return tag;
    }

    @Override
    public List<SysTag> listEnabledSystemTags() {
        LambdaQueryWrapper<SysTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysTag::getDeleted, 0)
                .eq(SysTag::getTagType, TagConstants.TYPE_SYSTEM)
                .eq(SysTag::getStatus, 1)
                .orderByAsc(SysTag::getId);
        return list(wrapper);
    }

    @Override
    public SysTag createSystemTag(SysTagCreateRequest request) {
        if (request == null) {
            throw new BusinessException(20001, "新增参数不能为空");
        }

        String displayName = TagNormalizationUtil.sanitizeDisplayName(request.getName());
        validateTagName(displayName);
        validateSystemTagGroup(request.getTagGroup());
        Integer status = normalizeStatus(request.getStatus());
        String normalizedName = TagNormalizationUtil.normalize(request.getName());
        validateNormalizedName(normalizedName);
        assertTagNormalizedNameAvailable(normalizedName, null);

        SysTag tag = new SysTag();
        tag.setName(displayName);
        tag.setNormalizedName(normalizedName);
        tag.setTagType(TagConstants.TYPE_SYSTEM);
        tag.setTagGroup(request.getTagGroup());
        tag.setStatus(status);
        tag.setUseCount(0);
        tag.setDeleted(0);
        save(tag);
        return tag;
    }

    @Override
    public SysTag updateTag(SysTagUpdateRequest request) {
        if (request == null || request.getId() == null) {
            throw new BusinessException(20001, "标签ID不能为空");
        }

        SysTag current = getActiveById(request.getId());
        Integer status = request.getStatus() == null ? current.getStatus() : normalizeStatus(request.getStatus());

        if (TagConstants.TYPE_SYSTEM.equals(current.getTagType())) {
            String nextName = StringUtils.hasText(request.getName())
                    ? TagNormalizationUtil.sanitizeDisplayName(request.getName())
                    : current.getName();
            String nextGroup = StringUtils.hasText(request.getTagGroup()) ? request.getTagGroup() : current.getTagGroup();

            validateTagName(nextName);
            validateSystemTagGroup(nextGroup);

            String normalizedName = TagNormalizationUtil.normalize(nextName);
            validateNormalizedName(normalizedName);
            assertTagNormalizedNameAvailable(normalizedName, current.getId());

            current.setName(nextName);
            current.setNormalizedName(normalizedName);
            current.setTagGroup(nextGroup);
            current.setStatus(status);
            updateById(current);
            return current;
        }

        if (StringUtils.hasText(request.getName()) && !request.getName().trim().equals(current.getName())) {
            throw new BusinessException(20001, "自由标签当前仅支持启用或禁用");
        }
        if (StringUtils.hasText(request.getTagGroup())) {
            throw new BusinessException(20001, "自由标签当前不支持修改标签分组");
        }

        current.setStatus(status);
        updateById(current);
        return current;
    }

    private void validateTagName(String name) {
        if (!StringUtils.hasText(name)) {
            throw new BusinessException(20001, "标签名称不能为空");
        }
        if (name.length() > 50) {
            throw new BusinessException(20001, "标签名称长度不能超过50个字符");
        }
    }

    private void validateNormalizedName(String normalizedName) {
        if (!StringUtils.hasText(normalizedName)) {
            throw new BusinessException(20001, "标签名称无效，请检查输入内容");
        }
        if (normalizedName.length() > 100) {
            throw new BusinessException(20001, "标签归一化名称长度不能超过100个字符");
        }
    }

    private void validateSystemTagGroup(String tagGroup) {
        if (!StringUtils.hasText(tagGroup)) {
            throw new BusinessException(20001, "系统标签分组不能为空");
        }
        if (!TagConstants.SYSTEM_TAG_GROUPS.contains(tagGroup)) {
            throw new BusinessException(20001, "标签分组不合法");
        }
    }

    private Integer normalizeStatus(Integer status) {
        Integer normalizedStatus = status == null ? 1 : status;
        if (!TagConstants.ENABLE_STATUS.contains(normalizedStatus)) {
            throw new BusinessException(20001, "标签状态不合法");
        }
        return normalizedStatus;
    }

    private void assertTagNormalizedNameAvailable(String normalizedName, Long excludeTagId) {
        LambdaQueryWrapper<SysTag> tagWrapper = new LambdaQueryWrapper<>();
        tagWrapper.eq(SysTag::getNormalizedName, normalizedName)
                .eq(SysTag::getDeleted, 0)
                .ne(excludeTagId != null, SysTag::getId, excludeTagId)
                .last("LIMIT 1");
        SysTag duplicateTag = getOne(tagWrapper, false);
        if (duplicateTag != null) {
            throw new BusinessException(20001, "标签名称已存在，请更换后重试");
        }

        LambdaQueryWrapper<SysTagAlias> aliasWrapper = new LambdaQueryWrapper<>();
        aliasWrapper.eq(SysTagAlias::getNormalizedName, normalizedName)
                .last("LIMIT 1");
        SysTagAlias duplicateAlias = sysTagAliasMapper.selectOne(aliasWrapper);
        if (duplicateAlias != null) {
            throw new BusinessException(20001, "标签名称与已有别名冲突，请先调整别名");
        }
    }
}
