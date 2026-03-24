var PORT = 9797;
var net = require('net');
var stripAnsi = require('strip-ansi');
var stylelint = require('stylelint');
var cosmiconfig = require('cosmiconfig');
var explorer = cosmiconfig('stylelint');

var tmp = require('tmp');
var fs = require('fs');
var path =  require('path');

var server = net.createServer(function (socket) {
  'use strict';

  var file, code = "";
  socket.setEncoding('utf8');

  socket.on('data', (json) => {

    var msg = JSON.parse(json);
    var msgId = msg[0];
    var msgContent = JSON.parse(msg[1]);
    var file = msgContent.file;

    var code = msgContent.code;

    var baseDir = path.dirname(file);
    explorer.load(baseDir)
      .then(configResult => {

        stylelint.lint({
          code: code,
          codeFilename: file,
          config: configResult.config,
          configBasedir: baseDir,
          formatter: function (results) {
            if (results[0].warnings) {
              const warnings = results[0].warnings;
              return warnings.map(w => {
                return results[0].source + ":" + w.line + ":" + w.column + " (" + w.severity + ")" + "  " + w.text;
              }).join("\n")
            } else {
              return "";
            }
          }
        }).then(result => {

          var errorfile = "";
          if (result.output) {
            var errorfile = tmp.fileSync().name;
            fs.writeFileSync(errorfile, stripAnsi(result.output));
          }
          socket.write(JSON.stringify([msgId, {
            messages: result.output,
            errorfile: errorfile
          }]));
        }).catch(e => {
          console.log(e)
        });

      })
      .catch(e => {
        console.log(e)
      })

  });

  socket.on('end', (json) => {

    //console.log('got end');

  });

});

/*function lint(code, file) {

  console.log(file)


  try {
    var config = cli.getConfigForFile(file);
  } catch(e) {
    return {
      error: 'Unable to parse config for file: ' + file + ',\n error: ' + e.message
    };
  }

  //format the globals config as array, or CLIEngine will complain
  config.globals = Object.keys(config.globals);

  //set fix to true
  config.fix = true;
  //config.color = false;

  var engine = new eslint.CLIEngine(config)

  var report = engine.executeOnText(code, file);
  var result = report.results[0];
  var fixed = result.output;

  var errorfile = "";
  if (result.messages.length) {
    var formatter = engine.getFormatter("compact");

    var formattedMessages = formatter(report.results);
    var errorfile = tmp.fileSync().name;
    fs.writeFileSync(errorfile, stripAnsi(formattedMessages));
  }

  if (fixed) {
    return {
      fixed: fixed,
      messages: result.messages,
      errorfile: errorfile
    };
  } else {
    return {
      messages: result.messages,
      errorfile: errorfile
    }
  }
}*/

server.on('error', (err) => {
  throw err;
});

server.listen(PORT, () => {
  console.log('server bound to port:', PORT);
});
