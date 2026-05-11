package com.lf.dao;

import com.lf.entity.SysHuagao;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author
 * @since 2024-02-16
 */
public interface SysHuagaoMapper extends BaseMapper<SysHuagao> {

    List<SysHuagao> selectFrontPage(Page<SysHuagao> page,
                                    @Param("name") String name,
                                    @Param("keyword") String keyword,
                                    @Param("normalizedKeyword") String normalizedKeyword,
                                    @Param("escapedKeyword") String escapedKeyword,
                                    @Param("escapedNormalizedKeyword") String escapedNormalizedKeyword,
                                    @Param("id") String id,
                                    @Param("type") String type,
                                    @Param("fenlei") String fenlei,
                                    @Param("shangjiaids") String shangjiaids,
                                    @Param("status") String status,
                                    @Param("tagId") Long tagId);

    List<Map<String, Object>> selectArtistWorkStats(@Param("artistIds") List<Integer> artistIds,
                                                    @Param("coverLimit") int coverLimit);
}
