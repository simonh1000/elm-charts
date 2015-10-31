module Main (main) where

import StartApp.Simple exposing (start)

import Effects exposing (Effects, Never)
import Html exposing (..)
import Task

import Chart exposing (..)
--
type alias Model =
    { labels : List String
    , values : List Float
    }
init =
    { labels = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon"]
    , values = [5, 9, 15, 2, 6]
    }

type Action = Dummy

update : Action -> Model -> Model
update action model = model

view : Signal.Address Action -> Model -> Html
view address model =
    chart model.values model.labels "Test message"

main =
  start
    { model = init
    , update = update
    , view = view
    }
