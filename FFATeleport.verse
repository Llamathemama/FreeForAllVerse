
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
DebugChannel := class(debug_draw_channel){}
FFATeleport := class(creative_device):
    @editable 
    Timer : timer_device = timer_device{}
    @editable
    Corner1 : creative_prop = creative_prop{}
    @editable
    Corner2  :creative_prop = creative_prop{}
    @editable
    EndGameDevice : end_game_device = end_game_device{}
    @editable
    var TestProp : creative_prop_asset = DefaultCreativePropAsset
    @editable
    var Rows : int = 3
    @editable
    var Collumns : int = 2
    @editable
    TestingEnabled : logic = false
    var IsPlayerAlive : [agent]logic = map{}
    var CurrentWinner : ?agent = false
    # GameEndEvent<public> : event() = event(){}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Players := GetPlayspace().GetPlayers()
        for(Player : Players){
            if:
                FortCharacter := Player.GetFortCharacter[]
                Agent := Player.GetFortCharacter[].GetAgent[]
                set IsPlayerAlive[Agent] = true
            then:
                FortCharacter.EliminatedEvent().Subscribe(SetEliminatedStatus)
                Print("Success")
        }
        Timer.SetMaxDuration(5.0)
        Timer.Start()
        Timer.SuccessEvent.Await()
        
        

        GameLoop()
    GameLoop()<suspends>:void=
        # Get Players and Shuffle them
        PlayerNonShuffled := GetPlayspace().GetPlayers()
        Players := Shuffle(PlayerNonShuffled)
        LobbyCount := Players.Length
        # Handle Transform
        DefaultTransform := Corner1.GetTransform().Translation
        DebugDraw:debug_draw = debug_draw{Channel := DebugChannel}
        DebugDraw.DrawArrow(Start := Corner1.GetTransform().Translation,End := Corner2.GetTransform().Translation)

        TwoDVector := vector2{X:= Corner1.GetTransform().Translation.X,Y:= Corner2.GetTransform().Translation.Y}
        XTransform : float = (Corner2.GetTransform().Translation.X - Corner1.GetTransform().Translation.X)/(Rows*1.0)
        YTransform : float = (Corner2.GetTransform().Translation.Y - Corner1.GetTransform().Translation.Y)/(Collumns*1.0)
        NewVector := Corner1.GetTransform().Translation + vector3{X:=XTransform,Y:=0.0,Z:=0.0}
        DebugDraw.DrawArrow(Corner1.GetTransform().Translation, NewVector)
        NewVector2 := Corner1.GetTransform().Translation + vector3{X:=0.0,Y:=YTransform,Z:=0.0}
        DebugDraw.DrawArrow(Corner1.GetTransform().Translation, NewVector)
        Print("X Transform = {XTransform}, Y Transform = {YTransform})")
        Print("Actual Difference X = {TwoDVector.X - Corner2.GetTransform().Translation.X}, Y = {TwoDVector.Y - Corner1.GetTransform().Translation.Y} ")
        if:
            NewLobbyCount := Sqrt(LobbyCount*1.0)   
            NewerLobbyCount := Int[NewLobbyCount]
        then:
            for(CollumnOfPlayers := 0..(Collumns - 1)){
                Print("Collumn Refresh")
                for(RowsOfPlayers := 0..(Rows - 1)){
                    Print("Player {CollumnOfPlayers*Rows + RowsOfPlayers}")
                    #if(Agent := Players[CollumnOfPlayers*4 + RowsOfPlayers],Character := Agent.GetFortCharacter[]){
                        #if(Character.TeleportTo[DefaultTransform + vector3{X:=XTransform*RowsOfPlayers,Y:=YTransform*CollumnOfPlayers,Z:=DefaultTransform.Z},rotation{}]){
                           # Print("Teleport Success")
                        #}
                    #}
                    ArrowEndPoint := (DefaultTransform + vector3{X:= XTransform*RowsOfPlayers,Y:= 0.0,Z:= 0.0})
                    DebugDraw.DrawArrow(Corner1.GetTransform().Translation, ArrowEndPoint)
                    if(TestingEnabled?, Agent := Players[0],Character := Agent.GetFortCharacter[]){
                        AbsoluteVector := DefaultTransform + vector3{X:=XTransform*RowsOfPlayers,Y:=YTransform*(CollumnOfPlayers),Z:=DefaultTransform.Z}
                        if(Character.TeleportTo[AbsoluteVector,rotation{}]){
                            Print("Teleport Success X ={XTransform*(RowsOfPlayers+1)},Y ={YTransform*(CollumnOfPlayers+1)},Z = {DefaultTransform.Z}")
                            SpawnProp(TestProp,AbsoluteVector,rotation{})
                        }
                    }
                    if(TestingEnabled = false, Agent := Players[CollumnOfPlayers*RowsOfPlayers+RowsOfPlayers],Character := Agent.GetFortCharacter[]){
                        AbsoluteVector := DefaultTransform + vector3{X:=XTransform*RowsOfPlayers,Y:=YTransform*(CollumnOfPlayers),Z:=DefaultTransform.Z}
                        if(Character.TeleportTo[AbsoluteVector,rotation{}]){
                            Print("Teleport Success X ={XTransform*(RowsOfPlayers)},Y ={YTransform*(CollumnOfPlayers)},Z = {DefaultTransform.Z}")
                            SpawnProp(TestProp,AbsoluteVector,rotation{})
                        }
                    
                        
                    
                        
                    }
                }
            }
        loop:
            Done := IsTheRoundOver()
            Sleep(1.0)
            if(Done?){
                break
            }
        # GameEndEvent.Await()
        if(Winner := CurrentWinner?){
           EndGameDevice.Activate(Winner)
        }
    SetEliminatedStatus(Result : elimination_result):void=
        if(set IsPlayerAlive[Result.EliminatedCharacter.GetAgent[]] = false){
            Print("Character Dead")
        }
    IsTheRoundOver():logic=
        var PlayersAlive : int = 0
        for(Key -> Value : IsPlayerAlive){
            if(Value = true){
                set PlayersAlive += 1
                set CurrentWinner = option{Key}
            }
        }
        if(PlayersAlive = 1){
            return true
        }
        else{
            return false
        }
        

            
                
                
            
        