
import syntaxHighlight from './formatter';

function displayLoading(isLoading) {
  if (isLoading) {
    document.getElementById('loading').style.display = 'block';
    document.getElementById('jsonResult').style.display = 'none';
  } else {
    document.getElementById('loading').style.display = 'none';
    document.getElementById('jsonResult').style.display = 'block';
  }
}

class Request {
  constructor(url) {
    this.url = url;
    this.requestData = {};

    this.loadEndpoint = this.loadEndpoint.bind(this);
    this.navigateJson = this.navigateJson.bind(this);
    this.loadData = this.loadData.bind(this);
  }

  navigateJson(event, element, state) {
    event.preventDefault();
    this.url = `${element.getAttribute('href')}.json`;
    window.history.pushState(state, element.getAttribute('href'), element.getAttribute('href'));
    this.loadEndpoint();
  }

  loadData(data) {
    // Ensure that the state is getting set properly
    window.history.replaceState(data, document.title, document.location.href);

    document.getElementById('jsonResult').innerHTML = syntaxHighlight(JSON.stringify(data, undefined, 4));

    const classname = document.getElementsByClassName('json-link');
    for (let i = 0; i < classname.length; i += 1) {
      classname[i].addEventListener('click', e => this.navigateJson(e, classname[i], data), false);
    }
  }


  loadEndpoint() {
    displayLoading(true);

    fetch(this.url).then(
      (response) => {
        displayLoading(false);

        // Reject promise if there's not any response
        if (response.status !== 200) {
          const error = new Error(response.statusText || response.status);
          error.response = response;
          return Promise.reject(error);
        }

        response.json().then(this.loadData);
        return true;
      },
    ).catch((err) => {
      document.getElementById('jsonResult').innerText = err;
    });
  }
}


export default Request;
