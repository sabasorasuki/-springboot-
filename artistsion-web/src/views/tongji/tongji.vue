<template>
    <div class="tongji-container">
      <el-row :gutter="20">
        <!-- 每日订单金额统计 - 折线图 -->
        <el-col :span="12">
          <el-card>
            <div slot="header">
              <span>每日订单金额统计</span>
            </div>
            <div id="amountLineChart" style="width: 100%; height: 400px;"></div>
          </el-card>
        </el-col>
        
        <!-- 每日订单数量统计 - 柱状图 -->
        <el-col :span="12">
          <el-card>
            <div slot="header">
              <span>每日订单数量统计</span>
            </div>
            <div id="countBarChart" style="width: 100%; height: 400px;"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" style="margin-top: 20px;">
        <!-- 订单状态分布 - 饼状图 -->
        <el-col :span="12">
          <el-card>
            <div slot="header">
              <span>订单状态分布</span>
            </div>
            <div id="statusPieChart" style="width: 100%; height: 400px;"></div>
          </el-card>
        </el-col>
        
        <!-- 用户订单统计 - 柱状图 -->
        <el-col :span="12">
          <el-card>
            <div slot="header">
              <span>用户订单统计（Top 10）</span>
            </div>
            <div id="userBarChart" style="width: 100%; height: 400px;"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20" style="margin-top: 20px;">
        <!-- 画稿销量统计 - 柱状图 -->
        <el-col :span="24">
          <el-card>
            <div slot="header">
              <span>画稿销量统计（Top 10）</span>
            </div>
            <div id="productBarChart" style="width: 100%; height: 400px;"></div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </template>
  
  <script>
  import api from '@/api/order.js';
  import * as echarts from 'echarts';
import { status } from 'nprogress';
  
  export default {
    data() {
      return {
        orderList: [],
        charts: {}
      };
    },
    methods: {
      // 获取订单列表
      getList() {
        // 获取所有订单数据用于统计
        api.getList({
          pageNo: 1,
          pageSize: 9999,
          status:"购物车1"
        }).then((response) => {
          this.orderList = response.data.rows || [];
          this.processDataAndRenderCharts();
        }).catch(error => {
          this.$message.error('获取订单数据失败');
          console.error(error);
        });
      },

      // 处理数据并渲染所有图表
      processDataAndRenderCharts() {
        this.$nextTick(() => {
          this.renderAmountLineChart();
          this.renderCountBarChart();
          this.renderStatusPieChart();
          this.renderUserBarChart();
          this.renderProductBarChart();
        });
      },

      // 每日订单金额统计 - 折线图
      renderAmountLineChart() {
        const dateMap = {};
        this.orderList.forEach(order => {
          if (order.xddate) {
            const date = order.xddate.split(' ')[0]; // 只取日期部分
            const amount = parseFloat(order.price) || 0;
            if (dateMap[date]) {
              dateMap[date] += amount;
            } else {
              dateMap[date] = amount;
            }
          }
        });

        const dates = Object.keys(dateMap).sort();
        const amounts = dates.map(date => dateMap[date]);

        const option = {
          title: {
            text: '每日订单金额统计',
            left: 'center'
          },
          tooltip: {
            trigger: 'axis',
            formatter: '{b}<br/>{a}: ¥{c}'
          },
          xAxis: {
            type: 'category',
            data: dates,
            axisLabel: {
              rotate: 45
            }
          },
          yAxis: {
            type: 'value',
            name: '金额(元)'
          },
          series: [{
            name: '订单金额',
            type: 'line',
            data: amounts,
            smooth: true,
            itemStyle: {
              color: '#409EFF'
            },
            areaStyle: {
              color: {
                type: 'linear',
                x: 0,
                y: 0,
                x2: 0,
                y2: 1,
                colorStops: [{
                  offset: 0, color: 'rgba(64, 158, 255, 0.3)'
                }, {
                  offset: 1, color: 'rgba(64, 158, 255, 0.1)'
                }]
              }
            }
          }]
        };

        const chart = echarts.init(document.getElementById('amountLineChart'));
        chart.setOption(option);
        this.charts.amountLine = chart;
      },

      // 每日订单数量统计 - 柱状图
      renderCountBarChart() {
        const dateMap = {};
        this.orderList.forEach(order => {
          if (order.xddate) {
            const date = order.xddate.split(' ')[0];
            dateMap[date] = (dateMap[date] || 0) + 1;
          }
        });

        const dates = Object.keys(dateMap).sort();
        const counts = dates.map(date => dateMap[date]);

        const option = {
          title: {
            text: '每日订单数量统计',
            left: 'center'
          },
          tooltip: {
            trigger: 'axis',
            formatter: '{b}<br/>{a}: {c}单'
          },
          xAxis: {
            type: 'category',
            data: dates,
            axisLabel: {
              rotate: 45
            }
          },
          yAxis: {
            type: 'value',
            name: '订单数(单)'
          },
          series: [{
            name: '订单数量',
            type: 'bar',
            data: counts,
            itemStyle: {
              color: '#67C23A'
            }
          }]
        };

        const chart = echarts.init(document.getElementById('countBarChart'));
        chart.setOption(option);
        this.charts.countBar = chart;
      },

      // 订单状态分布 - 饼状图
      renderStatusPieChart() {
        const statusMap = {};
        this.orderList.forEach(order => {
          const status = order.status || '未知';
          statusMap[status] = (statusMap[status] || 0) + 1;
        });

        const data = Object.keys(statusMap).map(status => ({
          name: status,
          value: statusMap[status]
        }));

        const option = {
          title: {
            text: '订单状态分布',
            left: 'center'
          },
          tooltip: {
            trigger: 'item',
            formatter: '{a} <br/>{b}: {c} ({d}%)'
          },
          legend: {
            orient: 'vertical',
            left: 'left'
          },
          series: [{
            name: '订单状态',
            type: 'pie',
            radius: ['40%', '70%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: true,
              formatter: '{b}: {c} ({d}%)'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: '16',
                fontWeight: 'bold'
              }
            },
            data: data
          }]
        };

        const chart = echarts.init(document.getElementById('statusPieChart'));
        chart.setOption(option);
        this.charts.statusPie = chart;
      },

      // 用户订单统计 - 柱状图
      renderUserBarChart() {
        const userMap = {};
        this.orderList.forEach(order => {
          const username = order.username || '未知用户';
          userMap[username] = (userMap[username] || 0) + 1;
        });

        const users = Object.keys(userMap)
          .sort((a, b) => userMap[b] - userMap[a])
          .slice(0, 10);
        const counts = users.map(user => userMap[user]);

        const option = {
          title: {
            text: '用户订单统计（Top 10）',
            left: 'center'
          },
          tooltip: {
            trigger: 'axis',
            formatter: '{b}<br/>{a}: {c}单'
          },
          xAxis: {
            type: 'category',
            data: users,
            axisLabel: {
              rotate: 45
            }
          },
          yAxis: {
            type: 'value',
            name: '订单数(单)'
          },
          series: [{
            name: '订单数量',
            type: 'bar',
            data: counts,
            itemStyle: {
              color: '#E6A23C'
            }
          }]
        };

        const chart = echarts.init(document.getElementById('userBarChart'));
        chart.setOption(option);
        this.charts.userBar = chart;
      },

      // 画稿销量统计 - 柱状图
      renderProductBarChart() {
        const productMap = {};
        this.orderList.forEach(order => {
          const name = order.name || '未知画稿';
          productMap[name] = (productMap[name] || 0) + 1;
        });

        const products = Object.keys(productMap)
          .sort((a, b) => productMap[b] - productMap[a])
          .slice(0, 10);
        const counts = products.map(product => productMap[product]);

        const option = {
          title: {
            text: '画稿销量统计（Top 10）',
            left: 'center'
          },
          tooltip: {
            trigger: 'axis',
            formatter: '{b}<br/>{a}: {c}单'
          },
          xAxis: {
            type: 'category',
            data: products,
            axisLabel: {
              rotate: 45
            }
          },
          yAxis: {
            type: 'value',
            name: '销量(单)'
          },
          series: [{
            name: '销量',
            type: 'bar',
            data: counts,
            itemStyle: {
              color: '#F56C6C'
            }
          }]
        };

        const chart = echarts.init(document.getElementById('productBarChart'));
        chart.setOption(option);
        this.charts.productBar = chart;
      }
    },
    created() {
      this.getList();
    },
    beforeDestroy() {
      // 销毁所有图表实例
      Object.keys(this.charts).forEach(key => {
        if (this.charts[key]) {
          this.charts[key].dispose();
        }
      });
    }
  };
  </script>

  <style scoped>
  .tongji-container {
    padding: 20px;
  }
  </style>
  