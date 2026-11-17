import Verso.Doc.Html
import VersoBlog
import Lang.Components.Icon

open Verso.Output
open Verso.Genre.Blog Template

namespace Lang
namespace Components

/--
The `aside` component is used to create a sidebar with a title and content.
-/
def aside (_title : String) (content : Html): Html :=
  html%{
    <aside>
      <nav class="post-index">
        {content}
      </nav>
    </aside>
  }

end Components
end Lang
