local Material = _G["_Material"]::any;

local Charms = require(game.ReplicatedStorage.Packages.wade.Charms);
local wade = require(game.ReplicatedStorage.Packages.wade);
local e = wade.element;
local c = wade.charm;

type p<T> = (T | wade.Charm<T> | wade.AnimCharm<T>)?;
export type Props = {[number]: (...any) -> ()} & {
    Badge: p<string | Color3>;
    BadgeSize: p<UDim2>;

    UserId: number | wade.Charm<number>;
    ThumbnailType: p<Enum.ThumbnailType>;
    ThumbnailSize: p<Enum.ThumbnailSize>;

    Size: p<UDim2>;
    Position: p<UDim2>;
    LayoutOrder: p<number>;
};

return function(props: Props)
    local img = c();

    if (not Charms.isCharm(props.ThumbnailType)) and (not Charms.isCharm(props.ThumbnailSize)) and (not Charms.isCharm(props.UserId)) then
        img:set(game.Players:GetUserThumbnailAsync(props.UserId, props.ThumbnailType or Enum.ThumbnailType.HeadShot, props.ThumbnailSize or Enum.ThumbnailSize.Size420x420));
    else
        local function f()
            local uid = props.UserId;
            if Charms.isCharm(uid) then
                uid = uid:get();
            end

            local thumbType = props.ThumbnailType;
            if Charms.isCharm(thumbType) then
                thumbType = thumbType:get();
            end

            local thumbSize = props.ThumbnailSize;
            if Charms.isCharm(thumbSize) then
                thumbSize = thumbSize:get();
            end

            img:set(game.Players:GetUserThumbnailAsync(uid, thumbType or Enum.ThumbnailType.HeadShot, thumbSize or Enum.ThumbnailSize.Size420x420));
        end

        if Charms.isCharm(props.UserId) then
            props.UserId:subscribe(f);
        end

        if Charms.isCharm(props.ThumbnailType) then
            props.UserId:subscribe(f);
        end

        if Charms.isCharm(props.ThumbnailSize) then
            props.UserId:subscribe(f);
        end

        f();
    end

    local badge = c();

    local function f()
        if not badge:get() then
            badge:wait();
        end

        local b = badge:get();
        local function a(x: string | Color3)
            if typeof(x) == "Color3" then
                b.BackgroundTransparency = 0;
                b.ImageTransparency = 1;
                b.BackgroundColor3 = x;
            else
                b.BackgroundTransparency = 0.8;
                b.ImageTransparency = 0;
                b.Image = x;
            end
        end

        if Charms.isCharm(props.Badge) then
            a(props.Badge:get());
        else
            a(props.Badge);
        end
    end

    if props.Badge ~= nil then
        task.spawn(f);

        if Charms.isCharm(props.Badge) then
            props.Badge:subscribe(f);
        end
    end

    return e "ImageLabel" {
        Size = props.Size or UDim2.fromOffset(32, 32),
        Position = props.Position or UDim2.fromScale(0.5, 0.5),
        LayoutOrder = props.LayoutOrder,

        BackgroundColor3 = Material.ButtonColor("Secondary"),

        Image = img,
        InheritedProps = props,
        Children = {
            e "UIAspectRatioConstraint" {
                AspectRatio = 1,
            },
            e "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                BorderStrokePosition = Enum.BorderStrokePosition.Outer,

                Color = Material.Lighten(Material.ButtonColor("Secondary"), -0.05),
                Thickness = 1,
            },
            e "UICorner" {
                CornerRadius = UDim.new(1, 0),
            },
            e "ImageLabel" {
                Size = props.BadgeSize or UDim2.fromOffset(10, 10),
                Position = UDim2.fromScale(1, 1),
                AnchorPoint = Vector2.new(0.8, 0.8),

                BackgroundColor3 = Material.ButtonColor("Secondary"),
                BackgroundTransparency = 1,
                Visible = props.Badge ~= nil,

                Charm = badge,
                Children = {
                    e "UICorner" {
                        CornerRadius = UDim.new(1, 0),
                    },
                    e "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        BorderStrokePosition = Enum.BorderStrokePosition.Center,

                        Color = Color3.new(0, 0, 0),
                        Thickness = 3,
                        Transparency = 0.8,

                        Children = e "UIGradient" {
                            Rotation = -90,
                            Transparency = Material.NumSeq{ {0, 0}, {0.4, 1}, {1, 1} },
                        },
                    },
                },
            },
        },
    };
end