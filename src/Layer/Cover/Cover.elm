port module Layer.Cover.Cover exposing
    ( id
    , init
    , view
    , def
    , Model
    , Msg
    )

import Html exposing (..)
import Html.Attributes exposing (style, class, attribute, contenteditable)

import Json.Encode as E
import Json.Decode as D

import Model.Layer.Blend.Html as Html
import Model.Layer.Blend.Html as Blend exposing (encode)
import Model.AppMode exposing (AppMode(..))
import Model.Product as Product exposing (Product)
import Model.Product exposing (..)

import Model.Layer.Context exposing (Context)
import Model.Layer.Def exposing (Kind(..), DefId, Index, makeIndex, Opacity(..))
import Model.Layer.Def as Layer exposing (Def)
import Model.Layer.Def as Layer exposing
    (initWith, passUpdate, bypass, noEncode, decodeTo, noSubscriptions)


id : DefId
id = "cover"


def : Layer.Def Model (Html Msg) Msg Html.Blend
def =
    { id = id
    , kind = Html
    , init = Layer.initWith init
    , encode = encode
    , decode = decode
    , subscribe = subscribe
    , update = update
    , absorb = Layer.bypass
    , view = view
    , gui = Nothing
    }


type alias Model =
    { productShown : Bool
    , logoShown : Bool
    , heading : String
    , subheading : String
    , headingSize : Float
    , subheadingSize : Float
    }


type Msg
    = HideProduct
    | ShowProduct
    | ChangeText String String Float Float
    | SetLogoVisibility Bool


type Scale = Scale Float


defaultSize = 110
defaultWidth = 1500.0
-- imageWidth : Int
-- imageWidth = 120
-- imageHeight : Int
-- imageHeight = 120
scaleFactor : Float
scaleFactor = 0.1


init : Model
init =
    { productShown = True
    , logoShown = True
    , heading = ""
    , subheading = ""
    , headingSize = 64
    , subheadingSize = 28
    }


update : Index -> Context -> Msg -> Model -> ( Model, Cmd Msg )
update index ctx msg model =
    case msg of
        ShowProduct ->
            ( { model | productShown = True }, Cmd.none )
        HideProduct ->
            ( { model | productShown = False }, Cmd.none )
        SetLogoVisibility isShown ->
            ( { model | logoShown = isShown }, Cmd.none )
        ChangeText heading subheading headingSize subheadingSize ->
            ( { model
                | heading = heading
                , subheading = subheading
                , headingSize = clamp 16 120 headingSize
                , subheadingSize = clamp 12 64 subheadingSize
              }
            , Cmd.none
            )


view : Index -> Context -> ( Maybe Html.Blend, Opacity ) -> Model -> Html Msg
view idx ctx ( maybeBlend, opacity ) model =
    let
        ( w, h ) = ctx.size
        ( x, y ) = ctx.origin
        scale = toFloat w / defaultWidth
        centerX = (toFloat w / 2) - toFloat x
        centerY = (toFloat h / 2) - toFloat y
        logoX = toFloat w - toFloat x - 0.1 * toFloat h
        logoY = toFloat h - toFloat y - 0.1 * toFloat h
        hasCustomText =
            not (String.isEmpty (String.trim model.heading))
                || not (String.isEmpty (String.trim model.subheading))
    in
        div
            [ class "cover-layer"
            , style "pointer-events" "none"
            --, style "mix-blend-mode" <| Blend.encode blend
            , style "position" "absolute"
            , style "top" "0px"
            , style "left" "0px"
            , style "font-size" <| String.fromInt defaultSize ++ "px"
            , style "font-family" "'Gotham', Helvetica, sans-serif"
            , style "font-weight" "170"
                -- , ("text-transform", "uppercase")
            , style "color" "white"
            ]
        ( if
            (ctx.mode == Production)
            || (ctx.mode == Player)
            || (ctx.mode == TronUi Production) then
            [ if hasCustomText then
                coverText ctx ( centerX, centerY ) model
              else if model.productShown then
                div []
                    [ productName
                        ctx.product
                        ( centerX, centerY )
                        ( maybeBlend |> Maybe.withDefault Blend.Normal )
                        opacity
                        ( Scale <| 0.8 * scale )
                    -- , slogan
                    --     ctx.product
                    --     ( centerX, centerY )
                    --     ( maybeBlend |> Maybe.withDefault Blend.Normal )
                    --     opacity
                    --     ( Scale <| 0.8 * scale )
                    ]
              else text ""
            , if model.logoShown then
                logo ( logoX, logoY ) Blend.Normal ( Scale <| 0.6 * scale )
              else
                text ""
            ]
          else
            [
            -- title product
            --, logo product posX posY logoPath blend scale
            ]
        )


subscribe : Context -> Model -> Sub ( Layer.Index, Msg )
subscribe ctx model =
    Sub.batch
        [ switchCoverProductVisibility
            (\{ layer, isProductShown } ->
                if isProductShown then
                    ( makeIndex layer, ShowProduct )
                else
                    ( makeIndex layer, HideProduct )
            )
        , changeCoverText
            (\{ layer, heading, subheading, headingSize, subheadingSize } ->
                ( makeIndex layer, ChangeText heading subheading headingSize subheadingSize )
            )
        , switchCoverLogoVisibility
            (\{ layer, isLogoShown } ->
                ( makeIndex layer, SetLogoVisibility isLogoShown )
            )
        ]


-- Custom text stays readable when I Feel Lucky randomizes the artwork stats.
coverText : Context -> ( Float, Float ) -> Model -> Html a
coverText ctx ( centerX, centerY ) model =
    let
        ( width, height ) = ctx.size
        scale = min (toFloat width / 1200) (toFloat height / 630)
        px n = String.fromFloat n ++ "px"
        line className fontSize weight value =
            div
                [ class className
                , style "font-size" (px (fontSize * scale))
                , style "font-weight" weight
                , style "line-height" "1.2"
                ]
                [ text value ]
    in
    div
        [ class "cover-custom-text"
        , style "position" "absolute"
        , style "left" (px centerX)
        , style "top" (px centerY)
        , style "transform" "translate(-50%, -50%)"
        , style "width" (px (toFloat width * 0.82))
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "gap" (px (20 * scale))
        , style "text-align" "center"
        , style "font-family" "'JetBrains Mono', monospace"
        , style "color" "white"
        , style "mix-blend-mode" "normal"
        , style "opacity" "1"
        , style "white-space" "pre-wrap"
        , style "overflow-wrap" "anywhere"
        , style "text-shadow" "0 2px 12px rgba(0, 0, 0, 0.35)"
        ]
        ( [ if String.isEmpty (String.trim model.heading) then
                Nothing
            else
                Just (line "cover-heading" model.headingSize "700" model.heading)
          , if String.isEmpty (String.trim model.subheading) then
                Nothing
            else
                Just (line "cover-subheading" model.subheadingSize "400" model.subheading)
          ] |> List.filterMap identity
        )


productName : Product -> ( Float, Float ) -> Html.Blend -> Opacity -> Scale -> Html a
productName product pos blend opacity scale =
    let
        textPath = "./assets/" ++ Product.getTextLinePath product
        textSize = Product.getCoverTextSize product
    in
        image
            textPath
            ("product-name-layer product-name-layer-" ++ Product.encode product)
            pos
            textSize
            blend
            (Opacity 0.85) -- opacity
            scale


slogan : Product -> ( Float, Float ) -> Html.Blend -> Opacity -> Scale -> Html a
slogan product (posX, posY) blend (Opacity opacity) scale =
    div
        [ class
            ("text-layer--slogan text-layer--" ++ Product.encode product)
        , style "max-width" "800px"
        , style "mix-blend-mode" <| Blend.encode blend
        , style "opacity" <| String.fromFloat opacity
        , style "position" "absolute"
        , style "top" "0px"
        , style "left" "0px"

        , style "transform" <| "translate("
                ++ String.fromFloat posX  ++ "px, "
                ++ String.fromFloat posY  ++ "px)"
        , style "font-size" <| String.fromInt defaultSize ++ "px"
        , style "font-family" "'Gotham', Helvetica, sans-serif"
        , style "font-weight" "170"
              -- , ("text-transform", "uppercase")
        , style "color" "white"
        , contenteditable True
        ]
        [ text <| getSlogan product ]



logo : ( Float, Float ) -> Html.Blend -> Scale -> Html a
logo ( logoX, logoY ) blend scale =
    let
        logoPath = "./assets/" ++ Product.getLogoPath Product.JetBrains
        ( logoWidth, logoHeight ) = ( 90, 90 )
    in image
            logoPath
            ("logo-layer logo-layer-" ++ Product.encode JetBrains)
            ( logoX, logoY )
            ( logoWidth, logoHeight )
            blend
            (Opacity 1.0)
            scale


image : String -> String -> ( Float, Float ) -> ( Int, Int ) -> Html.Blend -> Opacity -> Scale -> Html a
image imagePath imgClass ( posX, posY ) ( imageWidth, imageHeight ) blend (Opacity opacity) (Scale scale) =
    div
        [ class imgClass
        ,
            { blend = Blend.encode blend
            , posX = posX
            , posY = posY
            , width = imageWidth
            , height = imageHeight
            , imagePath = imagePath
            , scale = scale
            }
            |> encodeStoredData
            |> E.encode 0
            |> attribute "data-stored"
        , style "mix-blend-mode" <| Blend.encode blend
        , style "opacity" <| String.fromFloat opacity
        , style "position" "absolute"
        , style "top" "0px"
        , style "left" "0px"
        , style "width" <| String.fromFloat ( toFloat imageWidth * scale ) ++ "px"
        , style "height" <| String.fromFloat ( toFloat imageHeight * scale ) ++ "px"
        , style "transform" <| "translate("
                ++ String.fromFloat (posX - (toFloat imageWidth * scale) / 2.0) ++ "px, "
                ++ String.fromFloat (posY - (toFloat imageHeight * scale) / 2.0) ++ "px)"
        , style "background-image" <| "url(\"" ++ imagePath ++ "\")"
        , style "background-repeat" "no-repeat"
        , style "background-position" "center center"
        , style "background-size" "contain"
        ]
        [ --img [ HAttrs.src logoPath, HAttrs.attribute "crossorigin" "anonymous" ] []
        ]


title : Product -> Html a
title product =
    div
        [ class
            ("text-layer--title text-layer--" ++ Product.encode product)
        , style "max-width" "800px"
--            ,("mix-blend-mode", Blend.encode blend)
--                , ("position", "absolute")
--                , ("top", toString posY ++ "px")
--                , ("left", toString posX ++ "px")
--                , ("transform", "scale(" ++ toString scale ++ ")")
        , style "font-size" <| String.fromInt defaultSize ++ "px"
        , style "font-family" "'Gotham', Helvetica, sans-serif"
        , style "font-weight" "170"
              -- , ("text-transform", "uppercase")
        , style "color" "white"
        , contenteditable True
        ]
        [ text <| getName product ]


type alias StoredData =
    { scale : Float
    , posX : Float
    , posY : Float
    , blend : String
    , imagePath : String
    , width : Int
    , height : Int
    }


encodeStoredData : StoredData -> E.Value
encodeStoredData s =
    E.object
        [ ( "scale", E.float s.scale )
        , ( "posX", E.float s.posX )
        , ( "posY", E.float s.posY )
        , ( "blend", E.string s.blend )
        , ( "imagePath", E.string s.imagePath )
        , ( "width", E.int s.width )
        , ( "height", E.int s.height )
        ]


encode : Context -> Model -> E.Value
encode ctx model =
    E.object
        [ ( "productShown", E.bool model.productShown )
        , ( "logoShown", E.bool model.logoShown )
        , ( "heading", E.string model.heading )
        , ( "subheading", E.string model.subheading )
        , ( "headingSize", E.float model.headingSize )
        , ( "subheadingSize", E.float model.subheadingSize )
        ]


decode : Context -> D.Decoder Model
decode ctx =
    D.map6 Model
        (D.field "productShown" D.bool)
        (D.oneOf [ D.field "logoShown" D.bool, D.succeed init.logoShown ])
        (D.oneOf [ D.field "heading" D.string, D.succeed init.heading ])
        (D.oneOf [ D.field "subheading" D.string, D.succeed init.subheading ])
        (D.oneOf [ D.field "headingSize" D.float, D.succeed init.headingSize ])
        (D.oneOf [ D.field "subheadingSize" D.float, D.succeed init.subheadingSize ])


port switchCoverProductVisibility :
    ( { layer : Layer.JsIndex
      , isProductShown : Bool
      }
    -> msg) -> Sub msg


port changeCoverText :
    ( { layer : Layer.JsIndex
      , heading : String
      , subheading : String
      , headingSize : Float
      , subheadingSize : Float
      }
    -> msg) -> Sub msg


port switchCoverLogoVisibility :
    ( { layer : Layer.JsIndex
      , isLogoShown : Bool
      }
    -> msg) -> Sub msg
