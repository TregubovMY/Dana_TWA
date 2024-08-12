function submitUserData(initData) {
  const fetchOptions = {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    body: JSON.stringify({ init_data: initData }),
  };

  fetch('/telegram_session', fetchOptions)
    .then(response => {
      if (response.redirected) {
        window.location.assign(response.url);
        return Promise.reject('Redirected'); // Останавливаем цепочку промисов
      }
      return response;
    })
    .then(response => {
      if (response.ok) {
        return response.text();
      } else if (response.status === 403) {
        return response.text().then(html => {
          document.documentElement.innerHTML = html;
          return Promise.reject('403 Forbidden');
        });
      } else {
        return Promise.reject(`Unexpected status: ${response.status}`);
      }
    })
    .then(pageContent => {
      document.body.innerHTML = pageContent;
      displayError('The response does not redirect.');
    })
    .catch(err => {
      if (err !== 'Redirected' && err !== '403 Forbidden') {
        displayError(`Error occurred: ${err}`);
      }
    });
}

function displayError(errorMessage) {
  const errorContainer = document.getElementById('error-container');
  if (errorContainer) {
    errorContainer.textContent = errorMessage;
  } else {
    const newErrorContainer = document.createElement('div');
    newErrorContainer.id = 'error-container';
    newErrorContainer.style.color = 'red';
    newErrorContainer.style.marginTop = '20px';
    newErrorContainer.textContent = errorMessage;
    document.body.appendChild(newErrorContainer);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const telegramInitData = window.Telegram.WebApp.initData;
  submitUserData(telegramInitData);
});
