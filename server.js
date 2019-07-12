var Jimp = require("jimp");
//jimp 
var fs = require("fs");
var QrCode = require("qrcode-reader")

function getQR(path) {
    var buffer = fs.readFileSync(path);
    Jimp.read(buffer, function (err, image) {
        if (err) {
            console.error(err);
            // TODO handle error
        }
        var qr = new QrCode();
        qr.callback = function (err, value) {
            if (err) {
                console.error(err);
                // TODO handle error
            }
            console.log(value.result);
            return getStopDetails(value.result)
        };
        qr.decode(image.bitmap);
    });
}

function getStopDetails(stop) {

    const MongoClient = require('mongodb').MongoClient;
    const uri = "mongodb+srv://abcd:Shopify123!@cluster0-7spym.mongodb.net/test?retryWrites=true&w=majority";

    MongoClient.connect(uri, function (err, db) {
        if (err) throw err;
        var dbo = db.db("busBooking");
        return dbo.collection("stopdetails").find({ "stopname": new RegExp(stop) }).toArray(function (err, result) {
            if (err) throw err;
            rtv = result;
            db.close();
            return rtv
        });
    })

}


var formidable = require('formidable'),
    http = require('http'),
    util = require('util');
    const MongoClient = require('mongodb').MongoClient;
    const uri = "mongodb+srv://abcd:Shopify123!@cluster0-7spym.mongodb.net/test?retryWrites=true&w=majority";

http.createServer(function (req, res) {
    if (req.url == '/upload' && req.method.toLowerCase() == 'post') {
        // parse a file upload
        var form = new formidable.IncomingForm();

        form.parse(req, function (err, fields, files) {

            var buffer = fs.readFileSync(files.upload.path);
            Jimp.read(buffer, function (err, image) {
                if (err) {
                    console.error(err);
                    // TODO handle error
                }
                var qr = new QrCode();
                qr.callback = function (err, value) {
                    if (err) {
                        console.error(err);
                        // TODO handle error
                    }
                    console.log(value.result);
                    MongoClient.connect(uri, function (err, db) {
                        if (err) throw err;
                        var dbo = db.db("busBooking");
                        dbo.collection("stopdetails").find({ "stopname": new RegExp(value.result) }).toArray(function (err, result) {
                            if (err) throw err;
                            res.end(JSON.stringify(result));
                            db.close();
                        });
                    })
                    // return getStopDetails(value.result)
                };
                qr.decode(image.bitmap);
            });

            //   res.writeHead(200, {'content-type': 'text/plain'});
            //   res.write('received upload:\n\n');
            //   res.write("Path - " + files.upload.path)
            //   res.end("results - "+getQR(files.upload.path))
            //   res.end(util.inspect({fields: fields, files: files}));
        });

        return;
    }

    res.writeHead(200, { 'content-type': 'text/html' });
    res.end(
        '<form action="/upload" enctype="multipart/form-data" method="post">' +
        '<input type="text" name="title"><br>' +
        '<input type="file" name="upload" multiple="multiple"><br>' +
        '<input type="submit" value="Upload" >' +
        '</form>' 
    );

}).listen(process.env.VCAP_APP_PORT || 3000);

