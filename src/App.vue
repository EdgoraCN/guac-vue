<template>
    <div class="container">
        <a style="position: fixed;" href="https://github.com/EdgoraCN/guac-vue">
            <img width="149" height="149"
                 src="@/assets/forkme.png"
                 class="attachment-full size-full" alt="Fork me on GitHub" data-recalc-dims="1">
        </a>
          
        <div id="app" v-if="!connect">
          <h1>Connect via server side configuration id </h1>
            <div class="field">
                <label for="scheme">Configration ID</label>
                <select v-model="selectId">
                  <option v-for="id in ids" :value="id" :key="id">{{ id }}</option>
                </select>
            </div>
            <div class="center">
                <button class="connect" @click="doConnectById()">Connect</button>
            </div>
            <h1>Connect via paramters </h1>
            <p>Enter connection information to connect</p>
            <div class="field">
                <label for="scheme">ID</label>
                <input type="text" v-model="id" id="id" placeholder="Configration ID">
            </div>
            <div class="field">
                <label for="scheme">Scheme/Protocol</label>
                <select v-model="scheme" id="scheme">
                  <option v-for="sc in schemes" :value="sc.value" :key="sc.value">{{ sc.text }}</option>
                </select>
            </div>

            <div class="field">
                <label for="hostname">Hostname or IP Address</label>
                <input type="text" v-model="hostname" id="hostname">
            </div>

            <div class="field">
                <label for="port">Port (if not default)</label>
                <input type="text" v-model="port" id="port">
            </div>

            <div class="field">
                <label for="user">User name</label>
                <input type="text" v-model="user" id="user">
            </div>

            <div class="field">
                <label for="pass">Password</label>
                <input type="password" v-model="pass" id="pass">
            </div>

            <div class="field">
                <label for="ignorecert">Ignore Certificate</label>
                <span>
              <input type="checkbox" v-model="ignoreCert" id="ignorecert">
            </span>
            </div>

            <div class="field">
                <label for="nla">Security</label>
                <input type="text" v-model="security" id="nla" placeholder="type nla here for Network Level Authentication">
            </div>

            <div class="field">
                <label>Query string</label>
                <span class="pl-1">{{scrubbedQuery}}</span>
            </div>

            <div class="field">
                <label for="forcehttp">Force HTTP Tunnel</label>
                <span><input type="checkbox" v-model="forceHttp" id="forcehttp"></span>
            </div>

             <div class="field">
                <label for="forcehttp">GUACD Server</label>
                <input type="text" v-model="guacd" id="guacd" placeholder="the custom CUACD server">
            </div>

            <div class="field">
                <label for="forcehttp">Allowed Users</label>
                <input type="text" v-model="access" id="access" placeholder="Usernames split with comma, leave this empty to allow all">
            </div>

            <div class="center">
                <button class="connect" @click="doConnect()">Connect</button>
            </div>
        </div>
        <guac-client v-else :query="query" :force-http="forceHttp"/>
    </div>
</template>

<script>
  import GuacClient from '@/components/GuacClient'

  export default {
    name: 'app',
    components: {
      GuacClient
    },
    data() {
      return {
        connect: false,
        scheme: 'ssh',
        hostname: '127.0.0.1',
        port: '22',
        user: '',
        pass: '',
        ignoreCert: true,
        security: '',
        forceHttp: false,
        guacd: '',
        access: '',
        id: '',
        ids:[],
        selectId:'',
        useId: false,
        schemes:[{text:"SSH",value:"ssh"},{text:"RDP",value:"rdp"},{text:"VNC",value:"vnc"},{text:"Telnet",value:"telnet"},{text:"Kubernetes",value:"kubernetes"}]
      }
    },
    computed: {
      queryObj() {
        return {
          scheme: this.scheme,
          hostname: this.hostname,
          port: this.port,
          'ignore-cert': this.ignoreCert,
          security: this.security,
          username: this.user,
          password: this.pass,
          guacd: this.guacd,
          id: this.id,
          access: this.access
        }
      },
      query() {
        const queryString = []
        if(this.useId){
          queryString.push(`id=${encodeURIComponent(this.selectId)}`)
        }else {
          for (const [k, v] of Object.entries(this.queryObj)) {
            if (v) {
              queryString.push(`${k}=${encodeURIComponent(v)}`)
            }
          }
        }
        return queryString.join("&")
      },
      scrubbedQuery() {
        return this.query.replace(/password=[^& ]+/, 'password=****')
      }
    },
    methods: {
      doConnect() {
        if (window.localStorage) {
          window.localStorage.setItem('query', JSON.stringify(this.queryObj))
        }
        this.useId = false;
        this.connect = true
      },
      doConnectById(){
        if(!this.selectId){
          alert("please Select one Congration ID");
          return;
        }
        this.useId = true;
        this.connect = true
      },
      async readIds () {
        const response = await this.$http.get('/config?ids=all');
        this.ids = response.data;
        if(this.ids&&this.ids.length>0){
          this.selectId = this.ids[0]
        }
      }
    },
    mounted() {
      if (window.localStorage && window.localStorage.getItem('query')) {
        let query
        try {
          query = JSON.parse(window.localStorage.getItem('query'))
        } catch (e) {
          window.localStorage.setItem('query', '{}')
          return
        }
        this.scheme = query.scheme
        this.hostname = query.hostname
        this.port = query.port
        this.ignoreCert = query['ignore-cert']
        this.nla = query.nla
        this.user = query.username
        this.pass = query.password
      }
      this.readIds();
    }
  }
</script>

<style>
    html, body {
        margin: 0;
        height: 100%;
        width: 100%;
    }

    .container {
        width: 100%;
        height: 100%;
    }

    #app {
        height: 100%;
        font-family: 'Avenir', Helvetica, Arial, sans-serif;
        font-size: 16pt;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        padding: 1rem;
    }

    h1 {
        text-align: center;
    }

    .field {
        display: grid;
        grid-template-columns: 300px 1fr;
        margin-bottom: 1rem;
    }

    label {
        text-align: right;
    }

    label::after {
        content: ': '
    }

    input,select {
        margin-left: 1rem;
        margin-right: 1rem;
        font-size: 16pt;
        border: 1px solid black;
        border-radius: 2px;
        padding-left: 0.5rem;
    }

    .center {
        text-align: center;
    }

    .connect {
        font-size: 16pt;
        background: none;
        border: 1px solid black;
        border-radius: 5px;
        padding: .5rem 1rem;
    }

    .pl-1 {
        padding-left: 1rem;
    }
</style>
