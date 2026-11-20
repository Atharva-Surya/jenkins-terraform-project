const request = require('supertest');
const app = require('../src/app');

describe('Demo app', () => {
  test('GET / returns the home page', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.text).toContain('Jenkins CI/CD');
  });

  test('GET /health returns UP', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ status: 'UP' });
  });

  test('GET /add/2/3 returns 5', async () => {
    const res = await request(app).get('/add/2/3');
    expect(res.statusCode).toBe(200);
    expect(res.body.result).toBe(5);
  });

  test('GET /add/x/3 returns 400', async () => {
    const res = await request(app).get('/add/x/3');
    expect(res.statusCode).toBe(400);
  });
});
