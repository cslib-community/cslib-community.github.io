import Verso.Doc.Html
import VersoBlog

import Lang.Components.Basic
import Lang.Components.Icon
import Lang.Components.ArchiveEntry

open Lang Components
open Verso Genre Blog Template
open Verso Output
open Verso Doc Output Doc.Html HtmlT FS

namespace Lang

def archiveEntry : Template := do
  let post : BlogPost ← param "post"
  let summary : Html ← param "summary"

  let target ← if let some p := (← param? "path") then
      pure <| p ++ "/" ++ (← post.postName')
    else post.postName'

  return #[Components.archiveEntry target post.contents.metadata post.contents.titleString summary none]

partial def removeWrapper : Html → String
  | .text s | .raw s => s
  | .element _ _ h => removeWrapper h
  | .seq hs => String.intercalate " " (hs.toList.map removeWrapper)

partial def addSlug : Html → Html
  | .text s => .text s
  | .raw s => .raw s
  | .element t a h =>
    match t with
    | "h1" | "h2" | "h3" | "h4" => .element t (a.push ("id", createSlug (removeWrapper h))) h
    | _ => .element t a (addSlug h)
  | .seq h => .seq (h.map addSlug)

partial def collectH1 (html : Html) (linkPrefix : String := "") : Option Html :=
    let res := (collect [] html |>.reverse)
    if ¬ res.isEmpty then
      let (html, _) := compact 2 res
      Lean.Html.element "ol" #[] #[Html.seq (html.toArray |>.map (Lean.Html.element "li" #[]))]
    else
      none
  where
    getLevel : Html → Nat
      | "h1" => 1
      | "h2" => 2
      | "h3" => 3
      | "h4" => 4
      | _ => 0

    collect (col : List (Nat × String)) : Html → List (Nat × String)
      | .text _ | .raw _ => col
      | .element t _ h =>
        match t with
        | "h1" | "h2" | "h3" | "h4" => (getLevel t, removeWrapper h) :: col
        | _ => collect col h
      | .seq h => h.foldl collect col

    compact (current : Nat) : List (Nat × String) → (List Html × List (Nat × String))
      | (level, str) :: xs =>
        if level = current then
          let slug := createSlug str
          let headingLink := Lean.Html.element "a" #[("href", s!"{linkPrefix}#{slug}")] #[Lean.Html.raw str]

          let (children, remaining) := compactChildren (level + 1) xs
          let item := if children.isEmpty then headingLink else Html.seq #[headingLink, Lean.Html.element "ol" #[] (Html.seq children.toArray)]
          let (siblings, final) := compact level remaining

          (item :: siblings, final)
        else if level < current then
          ([], (level, str) :: xs)
        else
          ([], (level, str) :: xs)
      | [] => ([], [])

    compactChildren (minLevel : Nat) : List (Nat × String) → (List Html × List (Nat × String))
      | (level, str) :: xs =>
        if level >= minLevel then
          let (item, remaining) := compact level ((level, str) :: xs)
          let (siblings, final) := compactChildren minLevel remaining
          (item.map (Lean.Html.element "li" #[]) ++ siblings, final)
        else
          ([], (level, str) :: xs)
      | [] => ([], [])

def postTemplate : Template := do
  let content ← param "content"
  let nav := collectH1 content
  let metadata ← param? "metadata"

  pure html%{
    <main class={s!"container"}>
    <div class={s!"{if nav.isSome then "post-grid" else "post-center"} post-page"} role="main">
      <article class="post-container" id={(metadata >>= (Post.Meta.htmlId)) |>.getD "post"}>
        <h1>{← param "title"}</h1>
        {match metadata with
          | none => Html.empty
          | some md => html%{
              <div class="metadata">
                {(md : Post.PartMetadata).authors.map (html%{<div class="author">{Lean.Html.text ·}</div>}) |>.toArray}
                <div class="date">
                  {md.date.toIso8601String}
                </div>
                {if md.categories.isEmpty then Html.empty
                  else html%{
                    <ul class="categories">
                      {md.categories.toArray.map (fun cat => html%{<li><a href={s!"../{cat.slug}"}>{cat.name}</a></li>})}
                    </ul>
                  }}
            </div>
          }}
        <div class="post-content">
          {addSlug content}
        </div>
      </article>
      {if let some nav := nav then
          html%{
            <nav class="post-index">
            <h1 class="title">
              {← param "title"}
            </h1>
            {nav}
          </nav>
          }
        else
          .empty}
    </div>
    </main>
  }
