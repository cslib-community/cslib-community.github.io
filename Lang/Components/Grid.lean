import VersoBlog
import Lang.Meta.Svg
import Lang.Components.Basic

open Lean Verso Output
open Lang.Components

namespace Lang
namespace Components

def gridSvg := svg("./static/svg/grid.svg")

/--
Grid background image.
-/
def grid :=
  html%{
    <div id="main-background" class="background-wrapper" aria-hidden="true">
      {gridSvg
        |> setAttribute "aria-hidden" "true"
        |> setAttribute "alt" "grid background"}
    </div>
  }

end Components
end Lang
