var fs = require('fs');
path = require('path'); 

module.exports = function (request, response) {
    console.log(request.params);
    console.log(__dirname);
    var jsonPath = path.join(__dirname, '..', '..', '..', 'fixtures', `${request.params.gw}.json`);
    console.log(jsonPath);
    var obj = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
    response.json(obj);
  }