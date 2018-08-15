
const JSON_REGEX = /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g;

// Inspiration for this function taken from the following
// https://stackoverflow.com/questions/4810841/how-can-i-pretty-print-json-using-javascript
function syntaxHighlight(json) {
  const newJson = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  return newJson.replace(JSON_REGEX, (match) => {
    let className = 'number';
    let innerElement = match;

    if (/^"/.test(match)) {
      if (/:$/.test(match)) {
        className = 'key';
      } else if (match.indexOf('://') > 0) {
        // Create a link for urls
        let url = match.replace('"', '').replace('https://swapi.co/api', '');
        url = url.slice(0, url.length - 2);
        innerElement = `<a href="${url}" class="json-link string">${match}</a>`;
      } else {
        className = 'string';
      }
    } else if (/true|false/.test(match)) {
      className = 'boolean';
    } else if (/null/.test(match)) {
      className = 'null';
    }
    return `<span class="${className}">${innerElement}</span>`;
  });
}

export default syntaxHighlight;
