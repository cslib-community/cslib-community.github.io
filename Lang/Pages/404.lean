import VersoBlog

open Verso.Genre Blog Theme Template
open Verso.Output Html

def notFound : Html := {{
  <script src="/static/js/redirects.js" />
  <section class="404-container container active">
    <div class="error-container">
      <div>
        <div class="image-section">
          <img src="/static/png/hexapus-not.png" />
        </div>
      </div>
      <div class="text-section">
        <h1 class="error-title">"Oops! Page not found"</h1>
        <p class="error-description">
            "Looks like this page swam off into the digital ocean. Don’t worry, our hexapus has your back!"
        </p>
        <div class="action-buttons">
            <a href="." class="button primary">
              "Go Home"
            </a>
        </div>
      </div>
    </div>
  </section>
}}

#doc (Page) "Not Found" =>

%%%
showInNav := false
%%%

:::blob notFound
:::
