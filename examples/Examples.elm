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
        [ hBar model.values model.labels
            |> title "Example horizontal bar chart"
            |> toHtml
        , vBar model.values model.labels
            |> title "Example vertical bar chart"
            |> toHtml
        , pie model.values model.labels
            |> title "Example pie chart"
            |> toHtml
        ]

main =
  start
    { model = init
    , update = update
    , view = view
    }
