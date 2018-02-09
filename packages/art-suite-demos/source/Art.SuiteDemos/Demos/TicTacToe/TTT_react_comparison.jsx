body { // 10 // CSS tokens: 112  // Total tokens: 796
  font: 14px "Century Gothic", Futura, sans-serif;
  margin: 20px;
}

ol, ul { // 8
  padding-left: 30px;
}

.board-row:after { // 14
  clear:    both;
  content:  "";
  display:  table;
}

.status { // 6
  margin-bottom: 10px;
}

.square { // 41
  background:   #fff;
  border:       1px solid #999;
  float:        left;
  font-size:    24px;
  font-weight:  bold;
  line-height:  34px;
  height:       34px;
  margin-right: -1px;
  margin-top:   -1px;
  padding:      0;
  text-align:   center;
  width:        34px;
}

.square:focus { // 8
  outline: none;
}

.kbd-navigation .square:focus { // 9
  background: #ddd;
}

.game { // 9
  display: flex;
  flex-direction: row;
}

.game-info { // 7
  margin-left: 20px;
}

function Square(props) { // 33 // JSX tokens: 684
  return (
    <button className="square" onClick={props.onClick}>
      {props.value}
    </button>
  );
}

class Board extends React.Component { // 166
  renderSquare(i) { // 39
    return (
      <Square
        value={this.props.squares[i]}
        onClick={() => this.props.onClick(i)}
      />
    );
  }

  render() { // 119
    return (
      <div>
        <div className="board-row">
          {this.renderSquare(0)}
          {this.renderSquare(1)}
          {this.renderSquare(2)}
        </div>
        <div className="board-row">
          {this.renderSquare(3)}
          {this.renderSquare(4)}
          {this.renderSquare(5)}
        </div>
        <div className="board-row">
          {this.renderSquare(6)}
          {this.renderSquare(7)}
          {this.renderSquare(8)}
        </div>
      </div>
    );
  }
} // 1

class Game extends React.Component { // 7 => 372 total
  constructor(props) { // 39
    super(props);
    this.state = {
      history: [
        {
          squares: Array(9).fill(null)
        }
      ],
      stepNumber: 0,
      xIsNext: true
    };
  }

  handleClick(i) { // 117
    const history = this.state.history.slice(0, this.state.stepNumber + 1);
    const current = history[history.length - 1];
    const squares = current.squares.slice();
    if (calculateWinner(squares) || squares[i]) {
      return;
    }
    squares[i] = this.state.xIsNext ? "X" : "O";
    this.setState({
      history: history.concat([
        {
          squares: squares
        }
      ]),
      stepNumber: history.length,
      xIsNext: !this.state.xIsNext
    });
  }

  jumpTo(step) { // 25
    this.setState({
      stepNumber: step,
      xIsNext: (step % 2) === 0
    });
  }

  render() { // 183
    const history = this.state.history;
    const current = history[this.state.stepNumber];
    const winner = calculateWinner(current.squares);

    const moves = history.map((step, move) => {
      const desc = move ?
        'Go to move #' + move :
        'Go to game start';
      return (
        <li key={move}>
          <button onClick={() => this.jumpTo(move)}>{desc}</button>
        </li>
      );
    });

    let status;
    if (winner) {
      status = "Winner: " + winner;
    } else {
      status = "Next player: " + (this.state.xIsNext ? "X" : "O");
    }

    return (
      <div className="game">
        <div className="game-board">
          <Board
            squares={current.squares}
            onClick={i => this.handleClick(i)}
          />
        </div>
        <div className="game-info">
          <div>{status}</div>
          <ol>{moves}</ol>
        </div>
      </div>
    );
  }
}  // 1

ReactDOM.render(<Game />, document.getElementById("root")); // 17

function calculateWinner(squares) { // 6 => 146
  const lines = [ // 69
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];
  for (let i = 0; i < lines.length; i++) { // 71
    const [a, b, c] = lines[i];
    if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
      return squares[a];
    }
  }
  return null;
}