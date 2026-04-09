<template>
  <div>
    <div id="main" style="width: 1000px; height: 600px;" />
  </div>
</template>

<script>
import api from '@/api/order.js'
import * as echarts from 'echarts'

export default {
  data() {
    return {
      option: {
        title: {
          text: '每日金额统计'
        },
        tooltip: {
          trigger: 'axis'
        },
        xAxis: {
          data: []
        },
        yAxis: {},
        series: [
          {
            name: '金额',
            type: 'line',
            data: []
          }
        ]
      }
    }
  },
  created() {
    //   this.getList();
  },
  methods: {
    myEcharts() {
      const myChart = echarts.init(document.getElementById('main'))
      myChart.setOption(this.option)
    },
    getList() {
      api.getorder().then((response) => {
        response.data.forEach((dailyTotal) => {
          console.log(dailyTotal, 'dailyTotal')
          this.option.series[0].data.push(dailyTotal.totalAmount)
          this.option.xAxis.data.push(dailyTotal.orderDate)
        })
        this.myEcharts()
      })
    }
  }
}
</script>
