<template>
    <div class="mail-form">

  
      <el-card class="mail-form-card">
        <el-form :model="form" label-width="100px">
        
        <el-row>
          <el-col :span="24">
            <el-form-item label="标题">
              <el-input v-model="form.title" autocomplete="off"></el-input>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row>
          <el-col :span="24" >
            <el-form-item label="封面" >
                  <el-upload class="avatar-uploader" 
                  action="http://localhost:9999/oss/file/upload?module=photo"
                      :show-file-list="false" :on-success="handleAvatarSuccess">
                      <img v-if="form.photo"  :src="form.photo" class="avatar" />
                      <i v-else class="el-icon-plus avatar-uploader-icon"></i>
                  </el-upload>
              </el-form-item>
          </el-col>
        </el-row>

        
        <!-- <el-row>
          <el-col :span="24">
            <el-form-item label="分类">
              <el-select style="width: 100%" v-model="form.fenlei" clearable placeholder="请选择分类">
                  <el-option
                      v-for="item in allClasses"
                      :key="item.id"
                      :label="item.name"
                      :value="item.name">
                  </el-option>
                </el-select>

            </el-form-item>
          </el-col>
        </el-row> -->

      
    
          <el-row>
            <el-col :span="24">
              <el-form-item label="描述">
                <div id="editor" style="z-index: -1"></div>
              </el-form-item>
            </el-col>
          </el-row>
  
          
  
          <el-row>
            <el-col :span="24">
              <el-form-item>
                <el-button type="primary" @click="saveOrUpdate()">发布攻略</el-button>
              </el-form-item>
            </el-col>
          </el-row>
        </el-form>
      </el-card>
    </div>
  </template>
  
  <script>
     import { mapGetters } from 'vuex'
  import userApi from '@/api/userManage'
  import fenleiApi from '@/api/fenlei.js'
  import api from '@/api/fenxiang'
  import E from "wangeditor"
  export default {
    name: "Users",
    data(){
      return{
        editor: '',
        msg : {
          msg:""
        },
        tableData: [],
        total:0,
        query:{
          page:1,
          size:6,
          address:'',
          role:'1',
          stuId:'',
        },
        allClasses: [{//班级选择器
          id: '',//存储班级id
          typeName: '',//存储班级的名称
        }],
        dialogFormVisible: false,
        dialogFormVisible1: false,
        form: {
  
        },
        xiugaiform:{
          id:'',
          password:''
        },
        formLabelWidth: '60px'
  
      }
    },
    mounted() {
      this.setWangEditor()
  
  
    },
    created() {
        console.log(this.token)
        this.getInfo(this.token);
      this.id =  this.$route.params.id
      this.form.id =  this.$route.params.id
      // this.form.title =  this.$route.params.title
    //   this.form.content =  this.$route.params.content
      // this.form.zuoye =  this.$route.params.content

      console.log("12312",this.form.id,this.form.title,this.form.content)
      // debugger
      if (typeof this.id === "undefined") {
        // x 是 undefined
        this.id = null
      }else {
    //   this.getUserList()
    console.log(this.id ,"this.id134131 ")
        api.getById(this.id).then(response => {
        this.form = response.data;
        this.editor.txt.html(this.form.content)
        console.log(this.form ,"this.formformform ")
    })
    }
     
        //初始化调用方法
        this.loadAllClasses()
     
  
  
  
    },
    methods:{
      loadAllClasses() {
          this.allClasses = [];
          fenleiApi.getList1().then(response => {
              console.log(response,"response12312")
              let tmp = response.data.rows;//将表单信息提
                  for (let i = 0; i < tmp.length; i++) {//循环，表单的个数即为tmp的长度
                    this.allClasses.push({name: tmp[i].fenlei, id: tmp[i].id});
                  }
          });
          },

     
   handleAvatarSuccess(res,file){
        this.form.photo = `http://localhost:9999/oss/file/download?name=${res.data}`;
        console.log(this.form.photo,"oss12312")

        // 强制重新渲染
        this.$forceUpdate();
    },

      saveOrUpdate() {
            // 触发表单验证
            this.form.dianzan = "不是点赞";

                    this.form.content = this.editor.txt.html()
                    // 再提交请求给后台
                    api.saveOrUpdate(this.form).then(response => {
                        //成功提示
                        this.$message({
                            message: response.message,
                            type: 'success'
                        });
                        this.$router.push({name: 'fenxiang'});
                        this.$message({
                        message: '恭喜你，操作成功',
                        type: 'success'
                        });
                    })
        },
      getInfo(token) {
            userApi.getInfo(token).then(response => {
                this.forms = response.data.userList
                this.form.userids =this.forms.id
                this.form.username =this.forms.name
                // this.form.zuoye =this.forms.id
                // this.form.tijiaoren =this.forms.username
                console.log(this.forms, "123")
                console.log(this.form, "this.form")

                console.log(response, "response")
            })
        },
      setWangEditor() {
        // 创建编辑器
        this.editor = new E('#editor')
        this.editor.config.height= 500
        this.editor.config.zIndex=0
        // 配置 onchange 回调函数
        this.editor.config.onchange = function (newHtml) {
          console.log("change 之后最新的 html", newHtml);
        };
        // 配置触发 onchange 的时间频率，默认为 200ms
        this.editor.config.onchangeTimeout = 500; // 修改为 500ms
        // 插入网络图片的回调
        this.editor.config.linkImgCallback = function (src) {
          console.log('图片 src ', src)
          //console.log('图片文字说明',alt)
          //console.log('跳转链接',href)
        }
        // 自定义检查插入视频的回调
        this.editor.config.onlineVideoCallback = function (video) {
          // 自定义回调内容，内容成功插入后会执行该函数
          console.log('插入视频内容', video)
        }
        //关闭样式过滤
        this.editor.config.pasteFilterStyle = false
        // 配置 server 接口地址
        this.editor.config.uploadImgServer = 'http://localhost:9999/oss/file/uploadImg'
        this.editor.config.withCredentials = true
        this.editor.config.uploadFileName = 'myFileName'
        this.editor.config.uploadImgMaxSize = 5 * 1024 * 1024 //最大上传5M的图片
        this.editor.config.uploadImgMaxLength = 1 // 一次最多上传 1 个图片
        this.editor.config.uploadImgHooks = {
          customInsert: function (insertImg, result, editor) {
                   //获取后台返回的url
                   var url = `http://localhost:9999/oss/file/download?name=${result.data.url}`;
            console.log(url,"urlurlurlurlurl")
            insertImg(url);
          }
        };
        //this.editor.config.uploadImgShowBase64 = true
        // 配置alt选项
        this.editor.config.showLinkImgAlt = false
        // 配置图片超链接
        this.editor.config.showLinkImgHref = false
        this.editor.create()
      },
      ShowContent(){
        alert(this.editor.txt.html() )
        //alert(this.editor.txt.text())
      },
  
    },
    computed: {
        ...mapGetters([
            'token'
        ])
    }
  
  }
  </script>
  
  <style >
  
  .avatar-uploader .el-upload {
    border: 1px dashed #d9d9d9 !important;
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
  }
  
  .avatar-uploader .el-upload:hover {
    border-color: #409EFF;
  }
  
  .avatar-uploader .avatar-uploader-icon {
    font-size: 28px;
    color: #8c939d;
    width: 178px;
    height: 78px;
    line-height: 78px;
    text-align: center;
  }
  .mail-form {
    padding: 20px;
  }
  
  .mail-form-card {
    width: 80%;
    margin: 20px auto;
    padding: 20px;
  }
  
  
  .avatar-uploader img {
    width: 178px;
    height: 178px;
    display: block;
  }
  
  
  </style>