:- use_module( [ library(lists), io ] ).

% Define the players
% is_player1/1 succeeds when its argument is the player 1 character in
% the representation.
is_player1('X').
% is_player2/1 succeeds when its argument is the player 2 character in
% the representation
is_player2('O').

% other_player/2 succeeds when both its arguments are player representation characters, but
% they are different.
other_player('X', 'O').
other_player('O', 'X').

% is_merel/1 succeeds when its argument is either of the player
% characters.
is_merel(Something) :-
    is_player1(Something);
    is_player2(Something).

% connected/2 succeeds when its two arguments are the names of points
% on the board which are connected by a line (i.e., there is a valid
% move between them)
% All horizontal connections
connected(a, b).
connected(b, a).
connected(b, c).
connected(c, b).
connected(d, e).
connected(e, d).
connected(e, f).
connected(f, e).
connected(g, h).
connected(h, g).
connected(h, i).
connected(i, h).
connected(j, k).
connected(k, j).
connected(k, l).
connected(l, k).
connected(m, n).
connected(n, m).
connected(n, o).
connected(o, n).
connected(p, q).
connected(q, p).
connected(q, r).
connected(r, q).
connected(s, t).
connected(t, s).
connected(t, u).
connected(u, t).
connected(v, w).
connected(w, v).
connected(w, x).
connected(x, w).
% All vertical connections
connected(a, j).
connected(j, a).
connected(j, v).
connected(v, j).
connected(d, k).
connected(k, d).
connected(k, s).
connected(s, k).
connected(g, l).
connected(l, g).
connected(l, p).
connected(p, l).
connected(b, e).
connected(e, b).
connected(e, h).
connected(h, e).
connected(q, t).
connected(t, q).
connected(t, w).
connected(w, t).
connected(i, m).
connected(m, i).
connected(m, r).
connected(r, m).
connected(f, n).
connected(n, f).
connected(n, u).
connected(u, n).
connected(c, o).
connected(o, c).
connected(o, x).
connected(x, o).

% row/3 succeeds when its three arguments are (in order) a connected
% row, vertical or horizontal, in the board. Rows (horizontal)
row(a, b, c).
row(c, b, a).
row(d, e, f).
row(f, e, d).
row(g, h, i).
row(i, h, g).
row(j, k, l).
row(l, k, j).
row(m, n, o).
row(o, n, m).
row(p, q, r).
row(r, q, p).
row(s, t, u).
row(u, t, s).
row(v, w, x).
row(x, w, v).
% Rows (vertical)
row(a, j, v).
row(v, j, a).
row(d, k, s).
row(s, k, d).
row(g, l, p).
row(p, l, g).
row(b, e, h).
row(h, e, b).
row(q, t, w).
row(w, t, q).
row(i, m, r).
row(r, m, i).
row(f, n, u).
row(u, f, f).
row(c, o, x).
row(x, o, c).

% initial_board/1 succeeds when its argument represents the initial
% state of the board is empty at start and will only contain points that
% are placed by one of the players on the Board in the form [Point,Player]
initial_board([]).

% merel_on_board/2 succeeds when its first argument is a merel/point
% pair and its second is a representation of the merel positions on the board. Argument 2 is
% assumed to be instantiated.
merel_on_board([Point, Player], Board) :-
    member([Point, Player], Board).

% pair/3 succeeds when its first argument is a pair made up of its second, a point, and its
% third, a merel
pair([Point, none], Point, none).         % Represents an empty point
pair([Point, Player], Point, Player).      % Represents a point with a piece

% remove_opponent_piece/3 succeeds if a valid opponent piece to be
% removed is given if not, try again
% % Case 1: The piece can be removed
remove_opponent_piece(Board, Player, NewBoard) :-
    other_player(Player, Opponent),
    report_mill(Player),
    get_remove_point(Player, Point, Board),
    \+ check_for_mill(Point, Opponent, Board), % You can't remove a piece part of a mill
    delete(Board, [Point, Opponent], NewBoard),
    report_remove(Player, Point).

% Case 2: Allow removing a piece from a mill if no other options exist.
remove_opponent_piece(Board, Player, NewBoard) :-
    other_player(Player, Opponent),
    findall(Piece, (merel_on_board([Piece, Opponent], Board), \+ check_for_mill(Piece, Opponent, Board)), NonMillPieces),
    NonMillPieces = [], % If no non-mill pieces exist you are allowed to remove a mill piece
    format('No removable pieces outside mills available.\n', []),
    get_remove_point(Player, Point, Board),
    delete(Board, [Point, Opponent], NewBoard), % Allow removing a piece from a mill
    report_remove(Player, Point).

% Case 3: The piece can't be removed
remove_opponent_piece(Board, Player, NewBoard) :-
    format('You can not remove that point, choose a different one \n\n', []),
    remove_opponent_piece(Board, Player, NewBoard).

% Predicate to check if a placement forms a mill.
% A mill is formed if three points in a row are occupied by the same player's pieces.

check_for_mill(Point, Player, Board) :-
    % Define a row of three points (P1, P2, P3) that could form a mill.
    row(P1, P2, P3),

    % Generate all possible permutations of the three points.
    % I saw you could use this (https://www.swi-prolog.org/pldoc/man?predicate=permutation/2)
    % And used it because i had some problems with recognizing when a mill is formed in some cases, so i decided to test all possible possibilities
    % checks if Point is part of a row and if Adj1 and Adj2 are the other points in that row.
    permutation([P1, P2, P3], [Point, Adj1, Adj2]),

    % Verify that Adj1 and Adj2 are on the same team as the piece the player is about to play.
    merel_on_board([Adj1, Player], Board),
    merel_on_board([Adj2, Player], Board).

% has_valid_move succeeds if Player has at least one valid move (has a
% piece that is connected to an empty_point
has_valid_move(Player, Board) :-
    findall(Point, merel_on_board([Point, Player], Board), PlayerPoints),
    member(Point, PlayerPoints),
    connected(Point, AdjacentPoint),
    empty_point(AdjacentPoint, Board).

/*
% Test: Player has a valid move
test_has_valid_move :-
    Board = [[a, 'X'], [b, 'O']],
    has_valid_move('X', Board),
    has_valid_move('O', Board).


% Test: Player has no valid moves
test_has_no_valid_move :-
    Board = [[a, 'X'], [c, 'X'], [v, 'X'], [x, 'X'], [b, 'O'], [j, 'O'], [w, 'O'], [o, 'O']],
    \+ has_valid_move('X', Board).
*/

% and_the_winner_is/2 succeeds when its first argument represents a board, and the second
% is a player who has won on that board
% Case 1: Opponent has only two pieces left
and_the_winner_is(Board, Player) :-
    other_player(Player, Opponent),
    findall(_Piece, merel_on_board([_, Opponent], Board), OpponentPieces),
    length(OpponentPieces, OpponentPieceCount),
    OpponentPieceCount =< 2.

% Case 2: Opponent has no valid moves
and_the_winner_is(Board, Player) :-
    other_player(Player, Opponent),
    \+ has_valid_move(Opponent, Board).

% Updates the board by prepending a new [Point, Player] to the board
update_board(Point, Player, Board, NewBoard) :-
    % Check if the point is not already on the board
    \+ member([Point, _], Board),
    NewBoard = [[Point, Player] | Board].

% Updates board for a move
update_move(OldPoint, NewPoint, Player, Board, NewBoard) :-
    delete(Board, [OldPoint, Player], TempBoard),
    update_board(NewPoint, Player, TempBoard, NewBoard).
/*
% Test: Add a new piece to the board
test_update_board :-
    initial_board(Board),
    update_board(a, 'X', Board, NewBoard),
    member([a, 'X'], NewBoard).

% Test: Move a piece to a new point
test_update_move :-
    Board = [[a, 'X']],
    update_move(a, b, 'X', Board, NewBoard),
    member([b, 'X'], NewBoard),
    \+ member([a, 'X'], NewBoard).
*/

% Priority points for placement based on connectivity
% % This list has all the playable points in order of which have more connections
priority_points([e, k, t, n, h, l, q, m, b, j, w, o, g, p, r, i, d, s, u, f, a, v, x, c]).

/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/

% Heuristics

% Heuristic #1: if there is a mill to be made, make it
choose_place(Player, Point, Board) :-
    % Get the list of all possible points on the board
    priority_points(AllPoints),
    member(Point, AllPoints),
    empty_point(Point, Board), % Make sure the point is empty
    check_for_mill(Point, Player, Board),% Check if placing the piece on the point would complete a mill
    format('Mill completing point chosen: ~w \n', [Point]).

% Heuristic #2: if opponent is about to make a mill, block it if possible
choose_place(Player, Point, Board) :-
    other_player(Player, Opponent),
    priority_points(AllPoints),
    member(Point, AllPoints),
    empty_point(Point, Board), % Make sure the point is empty
    check_for_mill(Point, Opponent, Board), % Check if placing the piece on the point would form a mill for the opponent
    format('Blocking point chosen: ~w \n', [Point]).

% Heuristic #3: place pieces on points with many connections, where possible
choose_place(_Player, Point, Board) :-
    priority_points(PriorityList),
    member(Point, PriorityList), % Find the first empty point in the priority list
    empty_point(Point, Board). % Make sure the point is empty

/*****************************************************************************/
/*****************************************************************************/

% Heuristic #1: if there is a mill to be made, make it
choose_move(Player, OldPoint, NewPoint, Board) :-
    merel_on_board([OldPoint, Player], Board), % Make sure the player has a piece at OldPoint
    connected(OldPoint, NewPoint), % Make sure that OldPoint and NewPoint are connected
    empty_point(NewPoint, Board), % Make sure the point  is empty
    delete(Board, [OldPoint, Player], TempBoard),
    % Remove the OldPoint from the board
    % and check if placing it on NewPoint would form a mill
    check_for_mill(NewPoint, Player, TempBoard),
    format('Mill completing move: ~w -> ~w \n', [OldPoint, NewPoint]).

% Heuristic #2: if opponent is about to make a mill, block it if possible
% Same as the clause above except here we look at if NewPoint would form
% a mill for the opponent
choose_move(Player, OldPoint, NewPoint, Board) :-
    other_player(Player, Opponent),
    merel_on_board([OldPoint, Player], Board),
    connected(OldPoint, NewPoint),
    empty_point(NewPoint, Board),
    check_for_mill(NewPoint, Opponent, Board),
    format('Blocking move: ~w -> ~w \n', [OldPoint, NewPoint]).
% Heuristic #3: Otherwise, move your pieces together
choose_move(Player, OldPoint, NewPoint, Board) :-
    merel_on_board([OldPoint, Player], Board),
    connected(OldPoint, NewPoint),
    empty_point(NewPoint, Board),
    %Same as other clauses

    % Now here we will see if the NewPoint is connected to a merel of the same team,
    % but not OldPoint (or else it will always succeed)
    connected(NewPoint, Adjacent),
    Adjacent \= OldPoint,
    merel_on_board([Adjacent, Player], Board),
    format('Grouping move: ~w -> ~w \n', [OldPoint, NewPoint]).

% dumbly choose a move
choose_move(Player, OldPoint, NewPoint, Board) :-
    merel_on_board([OldPoint, Player], Board),
    connected(OldPoint, NewPoint),
    empty_point(NewPoint, Board),
    format('Connection move: ~w -> ~w \n', [OldPoint, NewPoint]).

/*****************************************************************************/
/*****************************************************************************/

% Heuristic #1: if opponent is able to make a mill, remove one of the relevant pieces
choose_remove(Player, Point, Board) :-
    other_player(Player, Opponent),
    merel_on_board([Point, Opponent], Board),
    connected(Point, Adjacent),
    merel_on_board([Adjacent, Opponent], Board),
    delete(Board, [Point, Opponent], TempBoard),
    \+ check_for_mill(Point, Opponent, TempBoard), % You can't delete a already formed mill
    format('Removing connected opponent piece: ~w \n', [Point]).

% If no strategic piece to remove, remove any opponent piece that is not in a mill
choose_remove(Player, Point, Board) :-
    other_player(Player, Opponent),
    merel_on_board([Point, Opponent], Board),
    delete(Board, [Point, Opponent], TempBoard),
    \+ check_for_mill(Point, Opponent, TempBoard).

% If opponent only has pieces in mill, then you can remove them
choose_remove(Player, Point, Board) :-
    other_player(Player, Opponent),
    merel_on_board([Point, Opponent], Board).

/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/

is_there_winner(0, Player, Board) :-
    and_the_winner_is(Board, Player),
    report_winner(Player).  % Announce winner and stop the game

is_there_winner(0, Player, Board) :-
    other_player(Player, NextPlayer),
    play(0, NextPlayer, Board).  % Keep on moving pieces

is_there_winner(MerelsLeft, Player, Board) :- % Third claude there is no winner so just go to next turn
    other_player(Player, NextPlayer),
    NewMerelsLeft is MerelsLeft - 1,
    play(NewMerelsLeft, NextPlayer, Board).  % Keep on placing pieces

is_there_mill(Point, MerelsLeft, Player, Board) :- % Checks if a mill has been formed and if so remove an opponent piece
    check_for_mill(Point, Player, Board),
    remove_opponent_piece(Board, Player, NewBoard),
    display_board(NewBoard),
    is_there_winner(MerelsLeft, Player, NewBoard). % Check if Player have won

is_there_mill(_Point, MerelsLeft, Player, Board) :- % No mill formed, so just check if there is a winner
    is_there_winner(MerelsLeft, Player, Board).

/*
% Test: A mill is formed
test_check_for_mill :-
    Board = [[a, 'X'], [b, 'X'], [c, 'X'], [v, 'X'], [w, 'X'], [x, 'X']],
    check_for_mill(a, 'X', Board),
    check_for_mill(b, 'X', Board),
    check_for_mill(c, 'X', Board),
    check_for_mill(v, 'X', Board),
    check_for_mill(w, 'X', Board),
    check_for_mill(x, 'X', Board),
    check_for_mill(j, 'X', Board),
    check_for_mill(o, 'X', Board).

% Test: No mill is formed
test_check_for_mill_fail :-
    Board = [[a, 'X'], [b, 'X'], [c, 'O'], [v, 'X'], [w, 'X'], [x, 'X']],
    \+ check_for_mill(a, 'X', Board),
    \+ check_for_mill(b, 'X', Board),
    \+ check_for_mill(w, 'O', Board),
    \+ check_for_mill(o, 'O', Board).
*/

is_there_mill_ai(Point, MerelsLeft, Player, Board) :- % Same as above except for the computer so just a couple of changes
    check_for_mill(Point, Player, Board),
    choose_remove(Player, RemovePoint, Board),
    delete(Board, [RemovePoint, _], NewBoard),
    report_remove(Player, RemovePoint),
    display_board(NewBoard),
    is_there_winner(MerelsLeft, Player, NewBoard).

is_there_mill_ai(_Point, MerelsLeft, Player, Board) :- % No mill formed, so just check if there is a winner
    is_there_winner(MerelsLeft, Player, Board).

% Start game
play :-
    welcome,
    initial_board(Board),
    display_board(Board),
    is_player1(Player),
    play(8, Player, Board).

/**************************************************************/
/******************     HUMAN VS HUMAN    *********************/
/**************************************************************/
/*
% Moving Phase: Begins when MerelsLeft = 0
% Human player's movement phase
play(0, Player, Board) :-
    format('HUMAN TURN \n', []),
    get_legal_move(Player, OldPoint, NewPoint, Board),
    update_move(OldPoint, NewPoint, Player, Board, TempBoard),
    display_board(TempBoard),
    is_there_mill(NewPoint, 0, Player, TempBoard).

% Human player's placement phase
play(MerelsLeft, Player, Board) :-
    format('NEW TURN, Merels left: ~w  \n', [MerelsLeft]),
    format('HUMAN TURN \n', []),
    get_legal_place(Player, Point, Board),
    update_board(Point, Player, Board, TempBoard),
    display_board(TempBoard),
    is_there_mill(Point, MerelsLeft, Player, TempBoard).
*/
/**************************************************************/
/*****************     COMPUTER VS HUMAN    *******************/
/**************************************************************/

% Human player's movement phase
play(0, Player, Board) :-
    is_player1(Player),
    format('HUMAN TURN \n', []),
    get_legal_move(Player, OldPoint, NewPoint, Board),
    update_move(OldPoint, NewPoint, Player, Board, TempBoard),
    display_board(TempBoard),
    is_there_mill(NewPoint, 0, Player, TempBoard).

% AI's movement phase
play(0, Player, Board) :-
    is_player2(Player),
    format('COMPUTER TURN \n', []),
    display_board(Board),
    choose_move(Player, OldPoint, NewPoint, Board),
    update_move(OldPoint, NewPoint, Player, Board, TempBoard),
    display_board(TempBoard),
    is_there_mill_ai(NewPoint, 0, Player, TempBoard).

% Human player's placement phase
play(MerelsLeft, Player, Board) :-
    is_player1(Player),
    format('NEW TURN, Merels left: ~w  \n', [MerelsLeft]),
    format('HUMAN TURN \n', []),
    get_legal_place(Player, Point, Board),
    update_board(Point, Player, Board, TempBoard),
    display_board(TempBoard),
    is_there_mill(Point, MerelsLeft, Player, TempBoard).

% AI's placement phase
play(MerelsLeft, Player, Board) :-
    is_player2(Player),
    format('NEW TURN, Merels left: ~w  \n', [MerelsLeft]),
    format('COMPUTER TURN \n', []),
    choose_place(Player, Point, Board),
    update_board(Point, Player, Board, TempBoard),
    display_board(TempBoard),
    is_there_mill_ai(Point, MerelsLeft, Player, TempBoard).


