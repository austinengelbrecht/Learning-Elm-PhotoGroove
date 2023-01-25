module Main exposing (..)

import Browser exposing (Document)
import Html exposing (Html, a, footer, h1, li, nav, text, ul)
import Html.Attributes exposing (classList, href)


type alias Model =
  { page : Page
  }


type Page 
  = Gallery 
  | Folders 
  | NotFound 


view : Model -> Document Msg
view model =
  let
    content = 
      text "This isn't even my final form"

  in 
  { title = "Photo Groove, SPA Style" 
    , body = 
      [ viewHeader model.page 
      , content 
      , viewFooter
      ]
  }


viewFooter : Html Msg 
viewFooter = 
  footer [] 
    [ text "One is never alone with a rubber duck. -Douglas Adams" ]


type Msg
  = NothingYet 


update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
  ( Model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model Msg
main =
  Browser.document
    { init = \_ -> ( page = Gallery, Cmd.none)
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

