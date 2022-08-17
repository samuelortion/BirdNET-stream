/*
 * Welcome to your app's main JavaScript file!
 *
 * We recommend including the built version of this JavaScript file
 * (and its CSS file) in your base layout (base.html.twig).
 */

// any CSS you import will output into a single css file (app.css in this case)
import './styles/app.css';
import './styles/menu.css';

// start the Stimulus application
import './bootstrap';

import feather from 'feather-icons';
feather.replace();

try {
    document.getElementsByClassName('prevent').map(
        (e) => e.addEventListener('click', (e) => e.preventDefault())
    );
} catch {
    console.debug('no prevent class found');
}