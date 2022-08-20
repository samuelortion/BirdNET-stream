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
import { version } from 'core-js';
feather.replace();

/** Update css variables --{header, footer}-height 
 * by querying elements real height */
(function () {
    let css_root = document.querySelector(':root');
    let header = document.getElementsByTagName('header')[0];
    let header_height = header.clientHeight;
    css_root.style.setProperty('--header-height', header_height + 'px');
    let footer = document.getElementsByTagName('footer')[0];
    let footer_height = footer.clientHeight;
    css_root.style.setProperty('--footer-height', footer_height + 'px');

})();

/** Add git version in web interface
 */
(function () {
    let version_span = document.querySelector('.version-number');
    version_span.textContent = `${VERSION}`;
    console.debug("Version: " + VERSION);
})();

try {
    document.getElementsByClassName('prevent').map(
        (e) => e.addEventListener('click', (e) => e.preventDefault())
    );
} catch {
    console.debug('no prevent class found');
}
