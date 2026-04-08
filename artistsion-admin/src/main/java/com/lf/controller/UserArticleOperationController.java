package com.lf.controller;

import com.lf.common.Result;
import com.lf.entity.UserArticleOperation;
import com.lf.service.impl.UserArticleOperationServiceImpl;
import org.apache.mahout.cf.taste.common.TasteException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * <p>
 *  前端控制器
 * </p>
 *
 * @author hwp
 * @since 2023-03-12
 */
@RestController
@RequestMapping("/userArticleOperation")
public class UserArticleOperationController {

    @Autowired
    UserArticleOperationServiceImpl userArticleOperationService;



    @GetMapping("/recommendations/{userid}")
    public Result<List<Long>> recommend(@PathVariable("userid") Integer userid) throws TasteException {
        System.out.println("Received userid: " + userid);
        List<Long> recommend = userArticleOperationService.recommend(userid);
        return Result.success(recommend); // 返回假数据
    }


    @PostMapping("/add")
    public Result<?> add(@RequestBody UserArticleOperation shetuan){
        userArticleOperationService.save(shetuan);
        return Result.success("添加成功");
    }

}
