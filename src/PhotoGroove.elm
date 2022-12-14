module PhotoGroove exposing (main)

import Html exposing (div, h1, img, text)
import Html.Attributes exposing (..)

-- view model = 
--   div [ class "content" ]
--     [ h1 [] [text "Photo Groove"] 
--     , div [ id "thumbnails"]
--       [ img [src "http://elm-in-action.com/1.jpeg" ] []
--       , img [src "http://elm-in-action.com/2.jpeg" ] []
--       , img [src "http://elm-in-action.com/3.jpeg" ] []
--       ]
--     ]

-- variable for photo url
urlPrefix = 
  "http://elm-in-action.com/"


-- creates the view for html
view model =
  div [ class "content" ]
    [ h1 [] [text "Photo Grove"] 
    , div [ id "thumbnails" ] (List.map viewThumbnail model)
    ]


-- This function puts the urls together
viewThumbnail thumb =
  img [ src (urlPrefix ++ thumb.url) ] []


-- This is a list of the different photos
initialModel = 
  { photos =
    [ { url = "1.jpeg" } 
    , { url = "2.jpeg" } 
    , { url = "3.jpeg" } 
    ]
    , selectedUrl = "1.jpeg"
  }


main = 
  view initialModel
