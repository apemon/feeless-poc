<template>
  <div>
    <b-container>
      <b-card no-body class="home">
        <h3>ETHEREUM</h3>
        <h2>1,000.12 ETH</h2>
        <h2>1,000.25 POW</h2>
        <b-row>
          <b-col>
          </b-col>
          <b-col lg="auto">
            <b-button class="button" size="lg" variant="outline-secondary">Send</b-button>
            <b-button class="button" size="lg" variant="outline-secondary">Receive</b-button>
            <b-button class="button" size="lg" variant="outline-secondary" disabled>Hello</b-button>
          </b-col>
          <b-col>
          </b-col>
        </b-row>
        <b-row>
          
        </b-row>
      </b-card>
    </b-container>
    
  </div>
</template>

<style>
.home {
  background-color: #ecf0f1;
  color: #3c3c3d;
  padding: 20px;
}
.button {
  margin: 20px;
}
</style>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import { Route } from 'vue-router'

@Component
export default class Home extends Vue {
  data() {
    return {
      msg: 'hello'
    }
  }
  mounted() {
    
  }
}
</script>
