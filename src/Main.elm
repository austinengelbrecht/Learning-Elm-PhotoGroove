module Main exposing (..)

import PhotoFolders as Folders 
import PhotoGallery as Gallery

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html, a, footer, h1, li, nav, text, ul)
import Html.Attributes exposing (classList, href)
import Html.Lazy exposing (lazy)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, s, string)
import Browser exposing (UrlRequest(..))


type alias Model =
  { page : Page
  , key : Nav.Key 
  , version : Float
  }


type Page 
  = Gallery Gallery.Model 
  | Folders Folders.Model 
  | NotFound 


type Route 
  = Gallery 
  | Folders 
  | SelectedPhoto String 


view : Model -> Document Msg
view model =
  let
    content = 
      case model.page of 
        FoldersPage folders ->
          Folders.view folders 
            |> Html.map GotFoldersMsg
        
        GalleryPage gallery ->
          Gallery.view gallery 
            |> Html.map GotGalleryMsg
        
        NotFound ->
          text "Not Found"

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

    navLink : Route -> { url : String, caption : String } -> Html Msg 
    navLink route { url, caption } =
      li [ classList [ ( "active", isActive { link = route, page = page }) ] ]
        [ a [ href url ] [ text caption ] ] 

  in
    nav []
      [ logo
      , links 
      ]


isActive : { link : Route, page : Page} -> Bool 
isActive { link, page } =
  case (link, page ) of 
    ( Gallery, GalleryPage _ ) -> True 
    ( Gallery, _ ) -> False 
    ( Folders, FoldersPage _ ) -> True 
    ( Folders, _ ) -> False 
    ( SelectedPhoto _, _ ) -> False 


type Msg
  = ClickedLink Browser.UrlRequest 
  | ChangedUrl Url  
  | GotFoldersMsg Folders.Msg
  | GotGalleryMsg Gallery.Msg


type UrlRequest
  = External String 
  | Internal Url 


update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
  case msg of 
    ClickedLink urlRequest ->
      case urlRequest of 
        Browser.External href ->
          ( model, Nav.load href )
        
        Browser.Internal url ->
          (model, Nav.pushUrl model.key (Url.toString url) )
        
    ChangedUrl url ->
      updateUrl url model 

    GotFoldersMsg foldersMsg ->
      case model.page of 
        FoldersPage folders ->
          toFolders model (Folders.update foldersMsg folders)
        
        _ ->
          ( model, Cmd.none )
    
    GotGalleryMsg galleryMsg ->
      case model.page of 
        GalleryMsg gallery ->
          toGallery model (Gallery.update galleryMsg gallery)
        
        _ ->
          ( model, Cmd.none )


toFolders : Model -> ( Folders.Model, Cmd Folders.Msg ) -> ( Model, Cmd Msg )
toFolders model ( folders, cmd ) = 
  ( { model | page = FoldersPage folders }
  , Cmd.map GotFoldersMsg cmd 
  )


toGallery : Model -> ( Gallery.Model, Cmd Gallery.Msg ) -> ( Model, Cmd Msg )
toGallery model ( gallery, cmd ) = 
  ( { model | page = GalleryPage gallery }
  , Cmd.map GotGalleryMsg cmd 
  )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of 
      GalleryPage gallery ->
        Gallery.subscriptions gallery 
          |> Sub.map GotGalleryMsg
      
      _ -> 
        Sub.none 


main : Program Float Model Msg
main =
  Browser.application
    { init = init
    , onUrlRequest = ClickedLink
    , onUrlChange = ChangedUrl
    , subscriptions = subscriptions 
    , view = view
    , update = update
    }


init : Float -> Url -> Nav.Key -> ( Model, Cmd Msg)
init flags url key =
  updateUrl url { page = NotFound, key = key, version = version }


updateUrl : Url -> Model -> ( Model, Cmd Msg )
updateUrl url model = 
  case Parser.parse parser url of 
    Just Gallery -> 
      Gallery.init model.version 
        |> toGallery model 
    
    Just Folders ->
      Folders.init Nothing
        |> toFolders model 

    Just (SelectedPhoto filename) ->
      Folders.init (Just filename)
        |> toFolders model 

    Nothing ->
      ( { model | page = NotFound }, Cmd.none )


parser : Parser (Page -> a) a
parser = 
  Parser.oneOf 
    [ Parser.map Folders Parser.top 
    , Parser.map Gallery (s "gallery")
    , Parser.map SelectedPhoto (s "photos" </> Parser.string)
    ]
  