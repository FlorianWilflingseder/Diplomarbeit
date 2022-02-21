
import * as React from 'react';
import Dashboard from "./Dashboard";

interface Props {
   name:
    string
}

class App extends React.Component<Props> {
  render() {
    const { name } = this.props;
    return (
        <Dashboard/>
    );
  }
}

export default App;
