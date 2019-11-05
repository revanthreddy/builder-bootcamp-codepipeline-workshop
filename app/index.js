var time = require('time');
exports.handler = (event, context, callback) => {
    var currentTime = new time.Date();
    currentTime.setTimezone("America/Chicago");
    callback(null, {
        statusCode: '200',
        body: 'The time in Chicago is: ' + currentTime.toString(),
    });
};