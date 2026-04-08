<template>
  <div id="map-page">
    <div id="container"></div> <!-- 地图容器 -->
    <div id="panel"></div> <!-- 路线面板 -->
  </div>
</template>

<script>
export default {
  name: "DrivingRoute",
  props: {
    startCity: {
      type: String,
      default: "南阳", // 默认值可以是一个假数据
    },
    startAddress: {
      type: String,
      default: "桐柏县", // 默认值可以是一个假数据
    },
    endCity: {
      type: String,
      default: "北京", // 默认值可以是一个假数据
    },
    endAddress: {
      type: String,
      default: "亦庄文化园(地铁站)", // 默认值可以是一个假数据
    },
  },
  mounted() {
    this.initMap();
  },
  methods: {
    initMap() {
      // 在加载地图脚本前配置安全密钥
      window._AMapSecurityConfig = {
        securityJsCode: "284e729f7e248b7d86e1f3cebf3f3a3f" // 安全密钥
      };

      // 加载高德地图脚本
      const script = document.createElement("script");
      script.src =
        "https://webapi.amap.com/maps?v=2.0&key=da1a0e47269d639dbb1defbca80501e5&plugin=AMap.Driving"; // API Key
      script.onload = () => {
        // 初始化地图
        const map = new AMap.Map("container", {
          resizeEnable: true,
          center: [116.397428, 39.90923], // 地图中心点
          zoom: 13, // 地图显示的缩放级别
        });

        // 构造路线导航类
        const driving = new AMap.Driving({
          map: map,
          panel: "panel",
        });

        // 使用传递的值进行驾车路线规划
        driving.search(
          [
            { keyword: this.startAddress, city: this.startCity },
            { keyword: this.endAddress, city: this.endCity },
          ],
          (status, result) => {
            if (status === "complete") {
              console.log("绘制驾车路线完成");
            } else {
              console.error("获取驾车数据失败：", result);
            }
          }
        );
      };
      document.head.appendChild(script);
    },
  },
};
</script>

<style scoped>
#map-page {
  width: 100%;
  height: 100%;
  position: relative;
}

#container {
  width: 100%;
  height: 100vh; /* 设置为视口高度 */
}

#panel {
  position: absolute;
  background-color: white;
  max-height: 90%;
  overflow-y: auto;
  top: 10px;
  right: 10px;
  width: 280px;
  border-radius: 4px;
}
</style>
