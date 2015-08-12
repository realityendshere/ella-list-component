var TOTAL_RECORDS = 103941;

var fetchTestObjects = function(offset, limit) {
  var max = TOTAL_RECORDS;
  var response = {};
  var data = [];
  var obj, i;

  for (i = offset; i < offset + limit; ++i) {
    obj = {
      id: i + 1,
      note: 'This is item ' + (i + 1),
      updatedAt: Date.now()
    };

    if (i < max) {
      data.push(obj);
    } else {
      i = offset + limit;
    }
  }

  response.data = data;
  response.meta = {offset: offset, limit: limit, total: max};

  return response;
};


module.exports = function(app) {
  var express = require('express');
  var noteRouter = express.Router();

  noteRouter.get('/', function(req, res) {
    var q, page, offset, limit;

    q = req.query;
    page = q.page;

    offset = parseInt(q.page.offset ? q.page.offset : 0, 10);
    limit = parseInt(q.page.limit ? q.page.limit : 50, 10);

    res.send(fetchTestObjects(offset, limit));
  });

  noteRouter.post('/', function(req, res) {
    res.status(201).end();
  });

  noteRouter.get('/:id', function(req, res) {
    res.send({
      'note': {
        id: req.params.id
      }
    });
  });

  noteRouter.put('/:id', function(req, res) {
    res.send({
      'note': {
        id: req.params.id
      }
    });
  });

  noteRouter.delete('/:id', function(req, res) {
    res.status(204).end();
  });

  app.use('/api/note', noteRouter);
};
