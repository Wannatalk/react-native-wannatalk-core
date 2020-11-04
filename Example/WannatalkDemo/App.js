/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */


import React from 'react';
import { Component } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
  Button,
} from 'react-native';

import {
  Header,
  LearnMoreLinks,
  Colors,
  DebugInstructions,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';

import WannatalkCore from 'react-native-wannatalk-core';
import { NativeEventEmitter, NativeModules } from 'react-native'

const WannatalkCoreEmitter = new NativeEventEmitter(WannatalkCore)



export default class App extends Component {

constructor() {
    super();
    this.state = {
      loggedIn: false,
    };
  }


componentDidMount() {
WannatalkCore.ShowProfileInfoPage(true);

        WannatalkCore.ShowGuideButton(false);
        WannatalkCore.ShowProfileInfoPage(true);
        // WannatalkCore.AllowAddParticipants(false);
        // WannatalkCore.AllowSendAudioMessage(false);
        WannatalkCore.EnableAutoTickets(true);
        WannatalkCore.ShowExitButton(true);
        // WannatalkCore.EnableChatProfile(false);

        // WannatalkCore.kEVENT_LOGIN
  // this.loginSubscription = WannatalkCoreEmitter.addListener('login-event', (data) => {

  // this.setState({loggedIn: data.userLoggedIn});

  // })

  // WannatalkCore.kEVENT_ERROR
  this.errorSubscription = WannatalkCoreEmitter.addListener('error-event', (data) => console.log(data))
 WannatalkCore.isUserLoggedIn((userLoggedIn) => {
  this.setState({loggedIn: userLoggedIn});
  })

}

componentWillUnmount() {
  // this.loginSubscription.remove();
  this.errorSubscription.remove();
}

loadLogin() {
  WannatalkCore.login((success, error) => {
    // console.log("login success: "+success+" error:"+error);
    if (success) {
      this.setState({loggedIn: true});
    }

  });
}

silentLogin() {

  WannatalkCore.silentLogin("useridentifier", { displayname: "username"}, (success, error) => {
    // console.log("silentLogin success: "+success+" error:"+error);
    if (success) {
      this.setState({loggedIn: true});
    }

  });
}

logout() {

  // updateUserImage
  // updateUserName
  // WannatalkCore.updateUserImage(null, (success, error) => {
  //   console.log("logout success: "+success+" error:"+error);
  //   if (success) {
  //     WannatalkCore.logout((success, error) => {
  //       console.log("logout success: "+success+" error:"+error);
  //       if (success) {
  //         this.setState({loggedIn: false});
  //       }
    
  //     });
  //   }

  // });


  WannatalkCore.logout((success, error) => {
    console.log("logout success: "+success+" error:"+error);
    if (success) {
      this.setState({loggedIn: false});
    }

  });
}

loadOrganizationProfile() {
  WannatalkCore.loadOrganizationProfile(true, (success, error) => {
    console.log("loadOrganizationProfile success: "+success+" error:"+error);

  });
}

loadUsers() {
  WannatalkCore.loadUsers((success, error) => {
    console.log("loadUsers success: "+success+" error:"+error);

  });
}

loadChatList() {
  WannatalkCore.loadChatList((success, error) => {
    console.log("loadChatList success: "+success+" error:"+error);

  });
}


// var CalendarManager = NativeModules.CalendarManager;
render() {
    return (

      <View style={styles.sectionContainer}>
      <StatusBar barStyle="dark-content" />

<View style={{margin:10}}>
  {!(this.state.loggedIn) && <Button onPress={ this.loadLogin.bind(this) }
          title=" Login " />}
</View>


<View style={{margin:10}}>
        {!(this.state.loggedIn) && <Button onPress={ this.silentLogin.bind(this) }
        title=" Silent Login " />}
</View>


<View style={{margin:10}}>
        {this.state.loggedIn && <Button
          onPress={ this.logout.bind(this) }
          title="Logout"
          color="#841584"
          accessibilityLabel="Learn more about this purple button"/>
        }
</View>

<View style={{margin:10}}>
  {this.state.loggedIn && <Button
            onPress={ this.loadOrganizationProfile.bind(this) }
            title="Org Profile"
            color="#841584"/>}
</View>

<View style={{margin:10}}>
  {this.state.loggedIn && <Button
            onPress={ this.loadUsers.bind(this) }
            title="Users"
            color="#841584"/>}
</View>

<View style={{margin:10}}>
  {this.state.loggedIn && <Button
            onPress={ this.loadChatList.bind(this) }
            title="Chat List"
            color="#841584"/>}
</View>


      </View>
    );
  }
}

const styles = StyleSheet.create({
  scrollView: {
    backgroundColor: Colors.lighter,
  },
  engine: {
    position: 'absolute',
    right: 0,
  },
  body: {
    backgroundColor: Colors.white,
  },
  sectionContainer: {
    marginTop: 150,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.black,
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
    color: Colors.dark,
  },
  highlight: {
    fontWeight: '700',
  },
  footer: {
    color: Colors.dark,
    fontSize: 12,
    fontWeight: '600',
    padding: 4,
    paddingRight: 12,
    textAlign: 'right',
  },
});
