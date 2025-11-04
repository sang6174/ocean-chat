
const server = Bun.serve({
  routes: {
    '/api/status': new Response('OK')
  },

  fetch() {
    return new Response('Not found', { status: 404 });
  },
});

console.log(`Server running at ${server.url}`);