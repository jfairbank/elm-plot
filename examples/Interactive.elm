module Interactive exposing (..)

import Svg
import Svg.Events
import Svg.Attributes
import Html exposing (h1, p, text)
import Html.Attributes
import Plot exposing (..)
import Plot.Line as Line
import Plot.Axis as Axis
import Plot.Tick as Tick
import Plot.Label as Label
import Plot.Hint as Hint


-- MODEL


type alias Model =
    { yourState : Int
    , plotState : Plot.State
    }


initialModel : Model
initialModel =
    { yourState = 0
    , plotState = Plot.initialState
    }



-- UPDATE


type Msg
    = YourClick
    | PlotInteraction (Plot.Interaction Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        YourClick ->
            ( { model | yourState = model.yourState + 1 }, Cmd.none )

        PlotInteraction interaction ->
            case interaction of
                Internal internalMsg ->
                    let
                        ( state, cmd ) =
                            Plot.update internalMsg model.plotState
                    in
                        ( { model | plotState = state }, Cmd.map PlotInteraction cmd )

                Custom yourMsg ->
                    update yourMsg model



-- VIEW


data1 : List ( Float, Float )
data1 =
    [ ( 0, 2 ), ( 1, 4 ), ( 2, 5 ), ( 3, 10 ) ]


data2 : List ( Float, Float )
data2 =
    [ ( 0, 0 ), ( 1, 5 ), ( 2, 7 ), ( 3, 15 ) ]


view : Model -> Html.Html Msg
view model =
    Html.div
        [ Html.Attributes.style [ ( "margin", "0 auto" ), ( "width", "800px" ) ] ]
        [ h1 [] [ text "Example with interactive plot!" ]
        , Html.map PlotInteraction (viewPlot model.plotState)
        , p [] [ text <| "You clicked a label " ++ toString model.yourState ++ " times! 🌟" ]
        , p [] [ text "P.S. No stylesheet is included here, so that's why the tooltip doesn't look very tooltipy." ]
        ]


viewPlot : Plot.State -> Svg.Svg (Interaction Msg)
viewPlot state =
    plotInteractive
        [ size ( 600, 300 )
        , margin ( 100, 100, 40, 100 )
        , id "PlotHint"
        , style [ ( "position", "relative" ) ]
        ]
        [ line
            [ Line.stroke "blue"
            , Line.strokeWidth 2
            ]
            data1
        , line
            [ Line.stroke "red"
            , Line.strokeWidth 2
            ]
            data2
        , xAxis
            [ Axis.line
                [ Line.stroke "grey" ]
            , Axis.tick
                [ Tick.delta 1 ]
            , Axis.label
                [ Label.view
                    [ Label.format (always "Click!")
                    , Label.customAttrs
                        [ Svg.Events.onClick (Custom YourClick)
                        , Svg.Attributes.style "cursor: pointer;"
                        ]
                    ]
                ]
            ]
        , hint [] (getHoveredValue state)
        ]


main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = (always Sub.none)
        , view = view
        }
