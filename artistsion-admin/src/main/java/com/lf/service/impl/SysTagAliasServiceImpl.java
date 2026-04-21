package com.lf.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.lf.common.exception.BusinessException;
import com.lf.common.request.SysTagAliasCreateRequest;
import com.lf.common.utils.TagNormalizationUtil;
import com.lf.dao.SysTagAliasMapper;
import com.lf.dao.SysTagMapper;
import com.lf.entity.SysTag;
import com.lf.entity.SysTagAlias;
import com.lf.service.SysTagAliasService;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import java.util.List;

@Service
public class SysTagAliasServiceImpl extends ServiceImpl<SysTagAliasMapper, SysTagAlias> implements SysTagAliasService {

    @Resource
    private SysTagMapper sysTagMapper;

    @Override
    public List<SysTagAlias> listByTagId(Long tagId) {
        if (tagId == null) {
            throw new BusinessException(20001, "标签ID不能为空");
        }
        ensureTagExists(tagId);
        LambdaQueryWrapper<SysTagAlias> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysTagAlias::getTagId, tagId)
                .orderByAsc(SysTagAlias::getId);
        return list(wrapper);
    }

    @Override
    public SysTagAlias createAlias(SysTagAliasCreateRequest request) {
        if (request == null || request.getTagId() == null) {
            throw new BusinessException(20001, "标签ID不能为空");
        }

        SysTag tag = ensureTagExists(request.getTagId());
        String aliasName = TagNormalizationUtil.sanitizeDisplayName(request.getAliasName());
        validateAliasName(aliasName);

        String normalizedName = TagNormalizationUtil.normalize(request.getAliasName());
        if (!StringUtils.hasText(normalizedName)) {
            throw new BusinessException(20001, "别名内容无效，请检查输入");
        }
        if (normalizedName.length() > 100) {
            throw new BusinessException(20001, "别名归一化名称长度不能超过100个字符");
        }
        if (normalizedName.equals(tag.getNormalizedName())) {
            throw new BusinessException(20001, "别名不能与标签标准名重复");
        }
        assertAliasNormalizedNameAvailable(normalizedName);

        SysTagAlias alias = new SysTagAlias();
        alias.setTagId(tag.getId());
        alias.setAliasName(aliasName);
        alias.setNormalizedName(normalizedName);
        save(alias);
        return alias;
    }

    @Override
    public void deleteAlias(Long id) {
        if (id == null) {
            throw new BusinessException(20001, "别名ID不能为空");
        }
        SysTagAlias alias = getById(id);
        if (alias == null) {
            throw new BusinessException(20001, "别名不存在");
        }
        removeById(id);
    }

    private SysTag ensureTagExists(Long tagId) {
        LambdaQueryWrapper<SysTag> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysTag::getId, tagId)
                .eq(SysTag::getDeleted, 0)
                .last("LIMIT 1");
        SysTag tag = sysTagMapper.selectOne(wrapper);
        if (tag == null) {
            throw new BusinessException(20001, "标签不存在");
        }
        return tag;
    }

    private void validateAliasName(String aliasName) {
        if (!StringUtils.hasText(aliasName)) {
            throw new BusinessException(20001, "别名不能为空");
        }
        if (aliasName.length() > 50) {
            throw new BusinessException(20001, "别名长度不能超过50个字符");
        }
    }

    private void assertAliasNormalizedNameAvailable(String normalizedName) {
        LambdaQueryWrapper<SysTag> tagWrapper = new LambdaQueryWrapper<>();
        tagWrapper.eq(SysTag::getNormalizedName, normalizedName)
                .eq(SysTag::getDeleted, 0)
                .last("LIMIT 1");
        SysTag duplicateTag = sysTagMapper.selectOne(tagWrapper);
        if (duplicateTag != null) {
            throw new BusinessException(20001, "别名与已有标签名称冲突");
        }

        LambdaQueryWrapper<SysTagAlias> aliasWrapper = new LambdaQueryWrapper<>();
        aliasWrapper.eq(SysTagAlias::getNormalizedName, normalizedName)
                .last("LIMIT 1");
        SysTagAlias duplicateAlias = getOne(aliasWrapper, false);
        if (duplicateAlias != null) {
            throw new BusinessException(20001, "别名已存在，请勿重复添加");
        }
    }
}
