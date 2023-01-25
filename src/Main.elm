module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, footer, h1, li, nav, text, ul)
import Html.Attributes exposing (classList, href)
import Html.Lazy exposing (lazy)
import Url exposing (Url)


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
      [ lazy viewHeader model.page 
      , content 
      , viewFooter
      ]
  }


viewFooter : Html Msg 
viewFooter = 
  footer [] 
    [ text "One is never alone with a rubber duck. -Douglas Adams" ]


viewHeader : Page -> Html Msg 
viewHeader page =
  let
    logo = 
      h1 [] [ text "Photo Groove"]
    
    links = 
      ul [] 
        [ navLink Folders { url = "/", caption = "Folders" }
        , navLink Gallery { url = "/gallery", caption = "Gallery" }
        ]

    navLink : Page -> { url : String, caption : String } -> Html Msg 
    navLink targetPage { url, caption } =
      li [ classList [ ( "active", page == targetPage ) ] ]
        [ a [ href url ] [ text caption ] ] 

  in
    nav []
      [ logo
      , links 
      ]


type Msg
  = NothingYet 


update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
  ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model Msg
main =
  Browser.application
    { init = init
    , onUrlRequest = \_ -> Debug.todo "handle URL request"
    , onUrlChange = \_ -> Debug.todo "handle URL changes"
    , subscriptions = subscriptions 
    , view = view
    , update = update
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg)
init flags url key =
  case url.path of 
    "/gallery" -> 
      ( { page = Gallery }, Cmd.none )
    
    "/" -> 
      ( { page = Folders }, Cmd.none )
    
    _ -> 
      ( { page = NotFound }, Cmd.none )