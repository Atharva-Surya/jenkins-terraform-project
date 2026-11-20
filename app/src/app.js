const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.send(
    '<h1>Jenkins CI/CD + Terraform Demo</h1>' +
      '<p>Name - Atharva Suryawanshi</p>' +
      '<p>Version 2 -This page was built, tested and deployed automatically by Jenkins.</p>'
  );
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

app.get('/add/:a/:b', (req, res) => {
  const a = Number(req.params.a);
  const b = Number(req.params.b);
  if (Number.isNaN(a) || Number.isNaN(b)) {
    return res.status(400).json({ error: 'Both parameters must be numbers' });
  }
  res.json({ result: a + b });
});

module.exports = app;
