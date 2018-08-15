/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import '@fortawesome/fontawesome-free/css/all.css'; //eslint-disable-line
import Request from './request';

document.addEventListener('DOMContentLoaded', () => {
  const r = new Request(`${window.location}.json`);
  r.loadEndpoint();
});

function loadState(event) {
  const r = new Request(window.location);
  // Let's only reload the data if we haven't previously fetched it.
  if (event.state === null) {
    r.loadEndpoint();
  } else {
    r.loadData(event.state);
  }
}

window.onpopstate = loadState;
