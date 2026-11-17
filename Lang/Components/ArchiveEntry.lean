import Verso.Doc.Html
import VersoBlog
import Lang.Components.Icon

open Verso.Output
open Verso.Genre.Blog Template

namespace Lang
namespace Components

private def extractText (html : Html) : String :=
  match html with
  | .text content | .raw content => content
  | .element _ _ contents => extractText contents
  | .seq contents =>
    contents.foldl (fun acc h => acc ++ extractText h) ""

private def htmlTextLength (html : Html) : Nat :=
  (extractText html).length

private def truncateHtml (html : Html) (maxLength : Nat) : Html :=
  if htmlTextLength html ≤ maxLength then
    html
  else
    let textContent := extractText html
    let words := textContent.splitToList (· == ' ')
    let rec buildResult (acc : String) (remaining : List String) : String :=
      match remaining with
      | [] => acc
      | word :: rest =>
        let newAcc := if acc.isEmpty then word else acc ++ " " ++ word
        if newAcc.length > maxLength
          then if acc.isEmpty
            then (word.take maxLength).toString
            else acc ++ "..."
        else buildResult newAcc rest
    let truncatedText := buildResult "" words
    Lean.Html.raw truncatedText

def archiveEntry (target : String) (metadata : Option Post.PartMetadata) (title : String) (summary : Option Html) (image : Option (String × String)) : Html :=
  html%{
    <li>
      {image.map (fun x => html%{<img src={x.fst} alt={x.snd}/>})}

      <div class="archive-content">

        {match metadata with
          | none => Html.empty
          | some md => html%{
            <div class="metadata">
              {(md : Post.PartMetadata).authors.map (html%{<div class="author">{Lean.Html.text ·}</div>}) |>.toArray}
              <div class="date">
                {md.date.toIso8601String}
              </div>
            </div>
          }}

        <a href={target} class="title">
          <span class="name">{title}</span>
        </a>

        {truncateHtml summary 200}

        <a href={target} class="read-more">
          Read more
          {Icon.arrowForward (width := "20px") (fill := "#000")}
        </a>
      </div>
    </li>
  }

end Components
end Lang
