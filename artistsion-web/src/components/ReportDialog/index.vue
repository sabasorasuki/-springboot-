<template>
  <el-dialog
    :visible.sync="dialogVisible"
    width="540px"
    :close-on-click-modal="false"
    custom-class="report-dialog"
    @close="handleClose"
  >
    <div class="report-hero">
      <p class="report-kicker">Content Report</p>
      <h2>{{ dialogTitle }}</h2>
      <p>我们会自动带入对象类型、对象 ID 和对象标题，只需要补充举报原因与必要说明。</p>
    </div>

    <div class="report-context">
      <div class="context-meta">
        <el-tag size="mini" type="danger" effect="plain">{{ targetType }}</el-tag>
        <el-tag size="mini" effect="plain">#{{ targetId }}</el-tag>
      </div>
      <div class="context-title">{{ targetTitle || '未命名对象' }}</div>
    </div>

    <el-form ref="reportForm" :model="form" :rules="rules" label-position="top" class="report-form">
      <el-form-item label="举报对象类型">
        <el-input :value="targetType" readonly />
      </el-form-item>
      <el-form-item label="举报原因" prop="reason">
        <el-select v-model="form.reason" style="width: 100%" placeholder="请选择举报原因">
          <el-option
            v-for="item in reasonOptions"
            :key="item"
            :label="item"
            :value="item"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="补充说明" prop="detail">
        <el-input
          v-model="form.detail"
          type="textarea"
          :rows="5"
          maxlength="500"
          show-word-limit
          placeholder="可补充问题细节、发现路径或希望管理员重点核查的内容"
        />
      </el-form-item>
    </el-form>

    <span slot="footer" class="dialog-footer">
      <el-button round @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" round :loading="submitting" @click="submitReport">提交举报</el-button>
    </span>
  </el-dialog>
</template>

<script>
import reportApi from '@/api/report'
import { REPORT_REASON_OPTIONS, redirectToAuthForAction } from '@/utils/reporting'
import { mapGetters } from 'vuex'

const createDefaultForm = () => ({
  reason: '',
  detail: ''
})

export default {
  name: 'ReportDialog',
  props: {
    value: {
      type: Boolean,
      default: false
    },
    targetType: {
      type: String,
      default: ''
    },
    targetId: {
      type: [String, Number],
      default: ''
    },
    targetTitle: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      submitting: false,
      form: createDefaultForm(),
      reasonOptions: REPORT_REASON_OPTIONS,
      rules: {
        reason: [
          { required: true, message: '请选择举报原因', trigger: 'change' }
        ],
        detail: [
          { min: 0, max: 500, message: '补充说明不能超过 500 个字符', trigger: 'blur' }
        ]
      }
    }
  },
  computed: {
    ...mapGetters(['token']),
    dialogVisible: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    },
    dialogTitle() {
      return `举报${this.targetType || '内容'}`
    }
  },
  watch: {
    value(visible) {
      if (!visible) {
        return
      }
      if (!this.token) {
        this.dialogVisible = false
        redirectToAuthForAction(this, '举报')
        return
      }
      this.resetForm()
    }
  },
  methods: {
    handleClose() {
      this.resetForm()
    },
    resetForm() {
      this.form = createDefaultForm()
      this.$nextTick(() => {
        if (this.$refs.reportForm) {
          this.$refs.reportForm.clearValidate()
        }
      })
    },
    submitReport() {
      this.$refs.reportForm.validate(async valid => {
        if (!valid) {
          return false
        }
        this.submitting = true
        try {
          const response = await reportApi.add({
            targetType: this.targetType,
            targetId: this.targetId,
            targetTitle: this.targetTitle,
            reason: this.form.reason,
            detail: this.form.detail
          })
          this.$message.success(response.message || '举报已提交')
          this.dialogVisible = false
          this.$emit('submitted')
        } finally {
          this.submitting = false
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.report-hero {
  padding: 24px;
  border-radius: 22px;
  background:
    radial-gradient(circle at top right, rgba(255, 209, 143, 0.24), transparent 38%),
    linear-gradient(135deg, #102542 0%, #1d436d 42%, #2f5a86 100%);
  color: #fff;
}

.report-kicker {
  margin: 0 0 8px;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: rgba(255, 255, 255, 0.72);
}

.report-hero h2 {
  margin: 0;
  font-size: 26px;
}

.report-hero p:last-child {
  margin: 12px 0 0;
  line-height: 1.7;
  color: rgba(255, 255, 255, 0.84);
}

.report-context {
  margin-top: 18px;
  padding: 18px 20px;
  border-radius: 18px;
  border: 1px solid #e7edf6;
  background: #f7f9fc;
}

.context-meta {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.context-title {
  margin-top: 12px;
  font-size: 16px;
  font-weight: 600;
  color: #102542;
  line-height: 1.6;
}

.report-form {
  margin-top: 20px;
}
</style>
