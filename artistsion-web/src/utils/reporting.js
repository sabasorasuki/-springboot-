export const REPORT_TARGET_TYPE_OPTIONS = ['作品', '社区内容', '反馈', '订单']

export const REPORT_REASON_OPTIONS = ['违规内容', '侵权/抄袭', '欺诈/异常交易', '骚扰辱骂', '垃圾广告', '其他']

export function redirectToAuthForAction(vm, actionLabel = '执行该操作') {
  vm.$message.warning(`请先登录后再${actionLabel}`)
  vm.$router.push(`/auth?redirect=${vm.$route.fullPath}`)
}

export function resolveReportTargetNavigation(targetType, targetId) {
  const normalizedId = targetId == null ? '' : String(targetId)
  if (!normalizedId) {
    return {
      canOpen: false,
      note: '当前举报记录缺少对象 ID，暂时无法直接定位原对象。'
    }
  }

  if (targetType === '作品') {
    return {
      canOpen: true,
      label: '查看作品详情',
      path: `/work/${normalizedId}`,
      kind: 'public'
    }
  }

  if (targetType === '社区内容') {
    return {
      canOpen: true,
      label: '查看帖子详情',
      path: `/post/${normalizedId}`,
      kind: 'public'
    }
  }

  if (targetType === '反馈') {
    return {
      canOpen: true,
      label: '进入反馈工单定位',
      path: '/liuyan/liuyan',
      query: { focusId: normalizedId },
      kind: 'admin'
    }
  }

  if (targetType === '订单') {
    return {
      canOpen: true,
      label: '进入交易订单定位',
      path: '/order/orderadglqb',
      query: { focusId: normalizedId },
      kind: 'admin'
    }
  }

  return {
    canOpen: false,
    note: '当前对象类型暂不支持直接跳转，请根据对象标题手动定位。'
  }
}
