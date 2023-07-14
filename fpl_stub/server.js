const jsonServer = require('json-server')
const server = jsonServer.create()
const router = jsonServer.router('db.json')
const middlewares = jsonServer.defaults()
const fs = require("fs").promises;

// Set default middlewares (logger, static, cors and no-cache)
server.use(middlewares)

// Current Gameweek
server.get('/api/game', async (req, res) => { 
    const data = await parseStubData('./data/gameweek.json')
    res.jsonp(data)
})

// Get Static Data
server.get( "/api/bootstrap-static", async (req, res) => {
    const data = await parseStubData(`./data/bootstrap_static.json`)
    res.jsonp(data)
  })

// Get Live Data
server.get( "/api/event/:gameweek/live", async (req, res) => {
    const gw = req.params['gameweek']
    const data = await parseStubData(`./data/live/${gw}.json`)
    res.jsonp(data)
  })

// Get League Details
server.get( "/api/league/:leagueId/details", async (req, res) => {
    const leagueId = req.params['leagueId']
    console.log(leagueId)
    if(leagueId == "48"){
      const data = await parseStubData(`./data/baguley/league_details.json`)
      res.jsonp(data)
    } else {
      const data = await parseStubData(`./data/chumpionship/league_details.json`)
      res.jsonp(data)
    }
  })

// Get Team GW Squad
server.get('/api/entry/:teamId/event/:gw', async (req, res) => {
  const teamId = req.params['teamId']
  const gw = req.params['gw']
  const data = await parseStubData(`./data/squads/${gw}/${teamId}.json`)
  res.jsonp(data)
})

// Get Transactions
server.get( "/api/draft/league/:leagueId/transactions", async (req, res) => {
    const leagueId = req.params['leagueId']
    if(leagueId == "48"){
      const data = await parseStubData(`./data/baguley/transactions.json`)
      res.jsonp(data)
    } else {
      const data = await parseStubData(`./data/chumpionship/transactions.json`)
      res.jsonp(data)
    }
  })

// Get Element Status
server.get( "/api/league/:leagueId/element-status", async (req, res) => {
    const leagueId = req.params['leagueId']
    if(leagueId == "48"){
      const data = await parseStubData(`./data/baguley/status.json`)
      res.jsonp(data)
    } else {
      const data = await parseStubData(`./data/chumpionship/status.json`)
      res.jsonp(data)
    }
  })

// Get League Trades
server.get( "/api/draft/league/:leagueId/trades", async (req, res) => {
    const leagueId = req.params['leagueId']
    if(leagueId == "48"){
      const data = await parseStubData(`./data/baguley/trades.json`)
      res.jsonp(data)
    } else {
      const data = await parseStubData(`./data/chumpionship/trades.json`)
      res.jsonp(data)
    }
  })

// To handle POST, PUT and PATCH you need to use a body-parser
// You can use the one used by JSON Server
server.use(jsonServer.bodyParser)
server.use((req, res, next) => {
  if (req.method === 'POST') {
    req.body.createdAt = Date.now()
  }
  // Continue to JSON Server router
  next()
})

// Use default router
server.use(router)
server.listen(3000, () => {
  console.log('JSON Server is running')
})

async function parseStubData(filePath) { 
    try {
        const data = await fs.readFile(filePath, "utf8").catch((err) => console.error('Failed to read file', err));
        return JSON.parse(data);
    } catch (error) {
        console.log(error)
        return {}
    }
 } 