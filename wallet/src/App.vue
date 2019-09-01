<template>
  <div id="app">
    <div id="nav">
      <router-link to="/">Home</router-link> |
      <router-link to="/about">About</router-link>
    </div>
    <router-view/>
  </div>
</template>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
#nav {
  padding: 30px;
}

#nav a {
  font-weight: bold;
  color: #2c3e50;
}

#nav a.router-link-exact-active {
  color: #42b983;
}

.tag {
  cursor: pointer;
}
.label {
  color: white;
  font-size: 24px;
}
.wallet-nav {
    text-align: right;
    padding: 10px;
}
.wallet-form {
    text-align: left;
    padding: 5px 20px;
    color: white;
}

/* on mobile */
@media only screen and (max-width: 1024px) {
    .wallet-main {
        width: 100%;
        background-color: #536dfe;
        color: white;
    }
    .wallet-body {
        padding-bottom: 2rem;
    }
    .button-group {
        margin: 40px 20px 20px 20px;
    }   
    .wallet-button {
        width: 100%;
        height: 60px;
        margin-bottom: 20px;
    }
}

@media only screen and (min-width: 1025px) {
    .wallet-main {
        width:70%;
        background-color: #536dfe;
        color: white;
    }
    .wallet-body {
        padding-bottom: 6rem;
        padding-top: 2rem;
    }
    .button-group {
        margin-top: 40px;
    }
    .wallet-button {
        min-width: 200px;
        max-width: 100%;
        margin: 0px 20px;
        text-align: center;
        height: 60px;
    }
}
</style>
