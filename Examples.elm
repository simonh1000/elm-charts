module Examples where

import StartApp.Simple exposing (start)

import Html exposing (..)
import Html.Attributes exposing (style)

import Chart exposing (..)

labels = ["Alpha", "Beta", "Gamma Gamma Gamma", "Delta", "Epsilon", "Omega"]
values = [5, 9, 5, 2, 6, 10]

type alias Model =
    { labels : List String
    , values : List Float
    }

init =
    { labels = List.take 5 labels
    , values = List.take 5 values
    }

type Action = Dummy

update : Action -> Model -> Model
update action model = model

view : Signal.Address Action -> Model -> Html
view address model =
    div [ style []
            -- [ ("height", "300px")         ]
        ]
        [ hBar model.values model.labels "Example horizontal bar chart"
        , vBar model.values model.labels "Example vertical bar chart"
        , pie model.values model.labels "Example pie chart"
        ]

main =
  start
    { model = init
    , update = update
    , view = view
    }
