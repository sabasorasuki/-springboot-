<template>
    <div>
        <!-- 搜索栏 -->
        <el-card id="search">
            <el-row>
                <el-col :span="18">
                    <el-input placeholder="菜单名字" v-model="searchModel.title" clearable> </el-input>
                    <el-button @click="getMenuList" type="primary" icon="el-icon-search" round>查询</el-button>
                </el-col>
                <el-col :span="6" align="right">
                    <el-button @click="openEditUI(null)" type="primary" icon="el-icon-plus" circle></el-button>
                </el-col>
            </el-row>
        </el-card>

        <!-- 结果列表 -->
        <el-card>
            <el-table :data="menuList" style="width: 100%;margin-bottom: 20px;" row-key="menuId" border default-expand-all
                :tree-props="{ children: 'children', hasChildren: 'hasChildren' }">
                <el-table-column prop="title" label="菜单名字" sortable>
                </el-table-column>
                <el-table-column prop="component" label="文件位置" sortable>
                </el-table-column>
                <el-table-column prop="path" label="访问路径" sortable>
                </el-table-column>
                <el-table-column prop="redirect" label="重定向" sortable>
                </el-table-column>
                <el-table-column prop="name" label="名字" sortable>
                </el-table-column>
                <el-table-column prop="icon" label="图标" sortable>
                </el-table-column>
                <el-table-column prop="parentId" label="父级" sortable>
                </el-table-column>
                <el-table-column prop="isLeaf" label="是否子节点">
                </el-table-column>
                <el-table-column label="操作" width="180">
                    <template slot-scope="scope">
                        <el-button @click="openEditUI(scope.row.menuId)" type="primary" icon="el-icon-edit" circle
                            size="mini"></el-button>
                        <el-button @click="deleteMenu(scope.row)" type="danger" icon="el-icon-delete" circle
                            size="mini"></el-button>
                        <el-button @click="openEditParent(scope.row.menuId)" v-if="scope.row.isLeaf == 'N'" type="primary"
                            icon="el-icon-plus" circle size="mini"></el-button>
                    </template>
                </el-table-column>
            </el-table>
        </el-card>

        <!-- 对话框 -->
        <el-dialog @close="clearForm" :title="title" :visible.sync="dialogFormVisible" :close-on-click-modal="false">
            <el-form :model="MenuForm">
                <el-form-item label="菜单名字" :label-width="formLabelWidth">
                    <el-input v-model="MenuForm.title" autocomplete="off"></el-input>
                </el-form-item>

                <el-form-item v-if="MenuForm.component != 'Layout'" label="文件位置" :label-width="formLabelWidth">
                    <el-input v-model="MenuForm.component" autocomplete="off"></el-input>
                </el-form-item>

                <el-form-item label="访问路径" :label-width="formLabelWidth">
                    <el-input v-model="MenuForm.path" autocomplete="off"></el-input>
                </el-form-item>

                <el-form-item v-if="MenuForm.isLeaf == 'N'" label="重定向" :label-width="formLabelWidth">
                    <el-input v-model="MenuForm.redirect" autocomplete="off"></el-input>
                </el-form-item>

                <el-form-item label="名字" :label-width="formLabelWidth">
                    <el-input v-model="MenuForm.name" autocomplete="off"></el-input>
                </el-form-item>

            </el-form>
            <div slot="footer" class="dialog-footer">
                <el-button @click="dialogFormVisible = false">取 消</el-button>
                <el-button type="primary" @click="saveRoute">确 定</el-button>
            </div>
        </el-dialog>

    </div>
</template>
  
  
<script>
import menuApi from '@/api/menuManage'

export default {
    data() {
        return {
            menuList: [],
            formLabelWidth: '130px',
            MenuForm: {},
            dialogFormVisible: false,
            title: '',
            searchModel: {
                pageNo: 1,
                pageSize: 999
            },
            roleList: [],
            total: 0,
            rules: {
                roleName: [
                    { required: true, message: '请输入角色名称', trigger: 'blur' },
                    { min: 3, max: 50, message: '长度在 3 到 50 个字符', trigger: 'blur' }
                ]
            }
        }
    },
    methods: {
        getAllMenu() {
            menuApi.getAllMenu().then(response => {
                this.menuList = response.data;
            })
        },
        getMenuList() {
            if (typeof this.searchModel.title !== "undefined" && this.searchModel.title !== '' && this.searchModel.title !== null) {
                menuApi.getMenuList(this.searchModel).then(response => {
                    this.menuList = response.data.rows;
                    console.log("12", response.data);
                });
            } else {
                this.getAllMenu();
            }
        },
        deleteMenu(role) {
            this.$confirm(`您确定删除菜单 ${role.title} ？`, '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                menuApi.deleteMenuById(role.menuId).then(response => {
                    this.$message({
                        type: 'success',
                        message: response.message
                    });
                    this.dialogFormVisible = false;
                    this.getAllMenu();
                });
            }).catch(() => {
                this.$message({
                    type: 'info',
                    message: '已取消删除'
                });
            });
        },
        saveRoute() {
            // 提交保存请求
            menuApi.saveRoute(this.MenuForm).then(response => {
                // 成功提示
                this.$message({
                    message: response.message,
                    type: 'success'
                });
                // 关闭对话框
                this.dialogFormVisible = false;
                // 刷新表格数据
                this.getAllMenu();
            });
        },
        clearForm() {
            this.MenuForm = {};
        },
        openEditUI(id) {
            console.log(id)
            if (id == null) {
                this.title = '新增菜单';
                this.MenuForm.parentId = "0";
                this.MenuForm.isLeaf = "N";
                this.MenuForm.component = "Layout";
                this.MenuForm.icon = "form";
                this.MenuForm.hidden = false;
            } else {
                this.title = '修改菜单';
                menuApi.getMenuById(id).then(response => {
                    this.MenuForm = response.data;
                    console.log(this.MenuForm, "this.MenuForm")
                });
            }
            this.dialogFormVisible = true;
        },
        openEditParent(id) {
            console.log(id)
            this.title = '修改菜单';
            menuApi.getMenuById(id).then(response => {
                this.MenuForm = response.data;
                this.MenuForm.parentId = this.MenuForm.menuId;
                this.MenuForm.isLeaf = "Y";
                this.MenuForm.redirect = null;
                this.MenuForm.menuId = null;
                this.MenuForm.path = null;
                this.MenuForm.name = null;
                this.MenuForm.title = null;
                this.MenuForm.component = null;
                console.log(this.MenuForm, "this.MenuForm")
            });
            this.dialogFormVisible = true;
        }
    },
    created() {
        this.getAllMenu();
    }
};
</script>
  
<style>
#search .el-input {
    width: 200px;
    margin-right: 10px;
}

.el-dialog .el-input {
    width: 85%;
}
</style>
  