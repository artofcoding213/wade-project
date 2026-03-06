local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;
local a = wade.animCharm;

local Material = require(script.Parent);
local Button = require(script.Parent.Button);

export type p<T> = Material.Prop<T>;
export type Props = Material.Props<{
    CloseButton: p<boolean>;

    Body: wade.ChildrenType;
    BodyPadding: p<UDim>;
    Size: p<"big" | "medium" | "small">;

    IsOpen: wade.Charm<boolean>;
    TitleText: p<string>;
    CancelText: p<string>;
    ActionText: p<string>;

    onCancel: (() -> boolean?)?;
    onAction: (() -> boolean?)?;
}>;

return function(props: Props)
    local ti = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out);

    local backdropTransparency = a(1, 0.2, ti);
    local globalTransparency = a(1, 0, ti);
    local backdrop = c();

    local scale = a(0.9, 1, ti);

    props.IsOpen:subscribe(function(x)
        if not backdrop:get() then
            backdrop:wait();
        end

        if x then
            backdropTransparency:play();
            globalTransparency:play();
            scale:play();
        else
            backdropTransparency:playReverse();
            globalTransparency:playReverse();
            scale:playReverse();
        end
    end);

    local function cancel()
        if props.onCancel then
            if props.onCancel() == true then
                return;
            end
        end

        props.IsOpen:set(false);
    end

    local function action()
        if props.onAction then
            if props.onAction() == true then
                return;
            end
        end

        props.IsOpen:set(false);
    end

    props.IsOpen:set(props.IsOpen:get());

    --local sizesMap = {
    --    ["big"] = UDim2.fromScale(0.825, 0.525),
    --    ["medium"] = UDim2.fromScale(0.675, 0.375),
    --    ["small"] = UDim2.fromScale(0.45, 0.315),
    --};

    local sizesMap = {
        ["big"] = UDim2.fromScale(0.85, 0.85),
        ["medium"] = UDim2.fromScale(0.725, 0.725),
        ["small"] = UDim2.fromScale(0.5, 0.5),
    };

    local bottomMenuAppear = props.ActionText ~= "" and props.CancelText ~= "";

    local size = c(sizesMap[Material.Extract(props.Size, "medium")]);
    if Charms.isCharm(props.Size) then
        (props.Size::wade.Charm<any>):subscribe(function(x)
            size:set(sizesMap[x]);
        end);
    end

    return {
        e "TextButton" {
            ZIndex = 900,

            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),

            Text = "",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = backdropTransparency,
            AutoButtonColor = false,
            Interactable = props.IsOpen,

            Charm = backdrop,
            [wade.Event.Activated] = cancel,
        },

        e "TextButton" {
            ZIndex = 9_11,

            Size = size,
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),

            Text = "",
            BackgroundColor3 = Color3.new(0.15, 0.15, 0.17),
            BackgroundTransparency = globalTransparency,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Interactable = props.IsOpen,

            Children = {
                e "UIAspectRatioConstraint" {
                    AspectRatio = 2,
                },
                e "UICorner" {
                    CornerRadius = UDim.new(0, 10),
                },
                e "UIScale" {
                    Scale = scale,
                },

                e "CanvasGroup" {
                    Size = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    GroupTransparency = globalTransparency,

                    ZIndex = 9_12,
                    InheritedZIndex = 9_13,

                    Children = {
                        e "UICorner" {
                            CornerRadius = UDim.new(0, 10),
                        },

                        e "Frame" {
                            Name = "Content",
                            Size = bottomMenuAppear and UDim2.new(1, 0, 1, -55) or UDim2.fromScale(1, 1),

                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,

                            Children = {
                                e "UIPadding" {
                                    PaddingLeft = props.BodyPadding or UDim.new(0, 20),
                                    PaddingRight = props.BodyPadding or UDim.new(0, 20),
                                    PaddingTop = props.BodyPadding or UDim.new(0, 20),
                                    PaddingBottom = props.BodyPadding or UDim.new(0, 20),
                                },

                                e "TextLabel" {
                                    Size = UDim2.new(1, 0, 0, 20),
                                    Position = UDim2.fromScale(0, 0),
                                    BackgroundTransparency = 1,

                                    TextColor3 = Color3.new(0.9, 0.9, 0.9),
                                    Text = props.TitleText or "Dialog",
                                    TextSize = 20,
                                    
                                    FontFace = Material.Font(Enum.FontWeight.Bold),
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                },
                                e "Frame" {
                                    Name = "UserContent",
                                    Size = UDim2.new(1, 0, 1, -25),
                                    Position = UDim2.fromScale(0, 1),
                                    AnchorPoint = Vector2.new(0, 1),

                                    BackgroundTransparency = 1,
                                    Children = props.Body,
                                },

                                Button {
                                    Position = UDim2.fromScale(1, 0),
                                    AnchorPoint = Vector2.new(1, 0),
                                    Size = UDim2.fromOffset(28, 28),

                                    Padding = UDim.new(0, 8),
                                    CornerRadius = UDim.new(1, 0),

                                    Text = "",
                                    Icon = "rbxassetid://10152135063",
                                    IconTranparency = 0.2,

                                    BackgroundColor = Material.ButtonColor("Secondary"),
                                    BackgroundTransparency = 0.8,

                                    Interactable = props.CloseButton or false,
                                    Visible = props.CloseButton or false,

                                    [wade.Event.Activated] = cancel,
                                },
                            },
                        },

                        if not bottomMenuAppear then nil else e "Frame" {
                            Name = "Actions",
                            Size = UDim2.new(1, 0, 0, 55),
                            Position = UDim2.fromScale(0, 1),
                            AnchorPoint = Vector2.new(0, 1),

                            BackgroundTransparency = 0.9,
                            BackgroundColor3 = Color3.new(1, 1, 1),
                            Children = {
                                e "UIListLayout" {
                                    SortOrder = Enum.SortOrder.LayoutOrder,
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    VerticalAlignment = Enum.VerticalAlignment.Center,
                                    Padding = UDim.new(0, 10),
                                },
                                e "UIPadding" {
                                    PaddingRight = UDim.new(0, 10),
                                },

                                Button {
                                    Text = props.CancelText or "Cancel",
                                    Style = "Secondary",
                                    Padding = UDim.new(0, 8),
                                    BackgroundTransparency = 0.8,

                                    Size = UDim2.fromOffset(0, 30),
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    [wade.Event.Activated] = cancel,
                                },
                                Button {
                                    Text = props.ActionText or "Action",
                                    Style = "Primary",
                                    Padding = UDim.new(0, 8),
                                    FontFace = Material.Font(Enum.FontWeight.SemiBold),

                                    Size = UDim2.fromOffset(0, 30),
                                    AutomaticSize = Enum.AutomaticSize.X,
                                    [wade.Event.Activated] = action,
                                },
                            },
                        },
                    },
                },
            },
        },
    };
end