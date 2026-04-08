<template>
  <div class="about">
    <the-header></the-header>
    <the-index></the-index>
    <the-footer></the-footer>
  </div>
</template>
<script>
import TheHeader from "@/views/about/the-header";
import TheFooter from "@/views/about/the-footer";
import TheIndex from "@/views/about/the-index";
export default {
  name: 'about',
  components: {TheIndex, TheFooter, TheHeader},

}
</script>