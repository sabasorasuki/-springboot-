<template>
  <div id="map-page">
    <div id="container" /> <!-- 鍦板浘瀹瑰櫒 -->
    <div id="panel" /> <!-- 璺嚎闈㈡澘 -->
  </div>
</template>

<script>
export default {
  name: 'DrivingRoute',
  props: {
    startCity: {
      type: String,
      default: '鍗楅槼' // 榛樿鍊煎彲浠ユ槸涓€涓亣鏁版嵁
    },
    startAddress: {
      type: String,
      default: 'Tongbai'
    },
    endCity: {
      type: String,
      default: '鍖椾含' // 榛樿鍊煎彲浠ユ槸涓€涓亣鏁版嵁
    },
    endAddress: {
      type: String,
      default: 'Yizhuang'
    }
  },
  mounted() {
    this.initMap()
  },
  methods: {
    initMap() {
      // 鍦ㄥ姞杞藉湴鍥捐剼鏈墠閰嶇疆瀹夊叏瀵嗛挜
      window._AMapSecurityConfig = {
        securityJsCode: '284e729f7e248b7d86e1f3cebf3f3a3f' // 瀹夊叏瀵嗛挜
      }

      // 鍔犺浇楂樺痉鍦板浘鑴氭湰
      const script = document.createElement('script')
      script.src =
        'https://webapi.amap.com/maps?v=2.0&key=da1a0e47269d639dbb1defbca80501e5&plugin=AMap.Driving' // API Key
      script.onload = () => {
        const AMap = window.AMap
        if (!AMap) {
          console.error('AMap SDK failed to load')
          return
        }
        // 鍒濆鍖栧湴鍥?
        const map = new AMap.Map('container', {
          resizeEnable: true,
          center: [116.397428, 39.90923], // 鍦板浘涓績鐐?
          zoom: 13 // 鍦板浘鏄剧ず鐨勭缉鏀剧骇鍒?
        })

        // 鏋勯€犺矾绾垮鑸被
        const driving = new AMap.Driving({
          map: map,
          panel: 'panel'
        })

        // 浣跨敤浼犻€掔殑鍊艰繘琛岄┚杞﹁矾绾胯鍒?
        driving.search(
          [
            { keyword: this.startAddress, city: this.startCity },
            { keyword: this.endAddress, city: this.endCity }
          ],
          (status, result) => {
            if (status === 'complete') {
              console.log('缁樺埗椹捐溅璺嚎瀹屾垚')
            } else {
              console.error('Failed to fetch driving route data', result)
            }
          }
        )
      }
      document.head.appendChild(script)
    }
  }
}
</script>

<style scoped>
#map-page {
  width: 100%;
  height: 100%;
  position: relative;
}

#container {
  width: 100%;
  height: 100vh; /* 璁剧疆涓鸿鍙ｉ珮搴?*/
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

