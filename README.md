<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="indexerd-md-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** based on https://github.com/othneildrew/Best-README-Template
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-RF.Fusion">About RF.Fusion</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#additional-references">Additional References</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
# About ERMx

ERMX is the acronym for "Estação Remota de Monitoramento" with the added letter "x" as a reference to a variable, since the objective is to provide a framework to construct a usefull spectrum monitoring station from assorted components, that may be adapted to the specific needs of each project.

This repository stores the documentation and scripts for the installation and configuration of the main components of the ERMx project.

The following figure presents a general view main elements for ERMx.

![General Diagram for the ERMx](./docs/img/ERMx_diagram.svg)

- **Antenna & Receiver:** Is the data acquisition front-end, from the RF receiving antennas to the digitizer and DSP units that provides data streams with IF IQ data, spectrum sweeps, demodulated data and alarms. Each equipment may provide a different set of data as output.
- **Processor:** Is a generic data processor running linux or windows. It's the local brain of the monitoring station, responsible to perform data requests to the acquisition front-end, any additional processing for data analysis and tagging. It also manage interfaces and the local data repository.
- **Support and Environment Control:** may be composed of several elements that are accessory to the measurement, such as temperature control, security detectors, cameras, UPS and power supply management, etc.
- **Router, Firewall and Network Interfaces:** may be composed of several elements that interconnect elements within the station and from it to the outside world. Common solutions provide up to 3 interfaces including an ethernet cable, an integrated 4G or 5G modem to connect to to the mobile WAN network and a VPN connection, that allows for a secure communication with the server core

<p align="right">(<a href="#indexerd-md-top">back to top</a>)</p>

# Modules and Microservices

The ERMx project is composed of several modules and microservices that are responsible for the configuration of the controller PC running MS Windows.

The current version is available at [**`WindowsSetupERMx.ps1`**](./src/Windows/WindowsSetupERMx.ps1) and performs simple configurations for the Windows OS to run the ERMx services.

The main modules for the next version are under construction and split the original module into several functions/modules in order to allow a more flexible configuration, including for other spectrum monitoring platforms.

They new modules are:

| Script module | Description |
| --- | --- |
| [**`config.json`**](./src/Windows/config.json) | Configuration parameters that define the powershell script behavior |
| [**`ovpn_setup.ps1`**](./src/Windows/ovpn_setup.ps1) | Script to install and configure the OpenVPN client including routes to remote LAN |
| [**`proxy_setup.ps1`**](./src/Windows/proxy_setup.ps1) | Script to configure proxy rules that enable the access to LAN services through the PC, mostly useful when the PC operates as gateway for the LAN |
| [**`rdp_setup.ps1`**](./src/Windows/firewall_setup.ps1) | Script to configure the Windows RDP access, includes creating user and setting firewall rules |
services to OpenVPN remote clients |
| [**`openssh_setup.ps1`**](./src/Windows/openssh_setup.ps1) | Script to install and configure the OpenSSH server, includes creating user and setting firewall rules |
| [**`smd_setup.ps1`**](./src/Windows/sms_setup.ps1) | Script to install and uninstall the Storage Manager Daemon |
| [**`smd_gui.ps1`**](./src/Windows/sms_setup.ps1) | Script that provides a gui to configure the Storage Manager Daemon |
| [**`storage_manager_daemon.ps1`**](./src/Windows/store_manage_service.ps1) | Catalog files within specific folders following the same algorithm described at [RF.Fusion](https://github.com/InovaFiscaliza/RF.Fusion/blob/main/src/agent/README.md). Additionally, manage the storage capacity to ensure minimum availability by deleting files using FIFO order. |
| [**`install_ermx.ps1`**](./src/Windows/install_ermx.ps1) | Script to install all the modules and microservices for ERMx in a single run |
| [**`setup_wizard.ps1`**](./src/Windows/install_ermx.ps1) | GUI interactive configuration and execution of setups |


<!-- ROADMAP -->
# Roadmap

* [ ] Create main repository and upload existing data
  * [ ] Create new structure for the project providing new GUI and CLI scripts

See the [open issues](https://github.com/othneildrew/Best-README-Template/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#indexerd-md-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
# Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#indexerd-md-top">back to top</a>)</p>

<!-- LICENSE -->
# License

Distributed under the GNU General Public License (GPL), version 3. See [`LICENSE.txt`](.\LICENSE) for more information.

For additional information, please check <https://www.gnu.org/licenses/quick-guide-gplv3.html>

This license model was selected with the idea of enabling collaboration of anyone interested in projects listed within this group.

It is in line with the Brazilian Public Software directives, as published at: <https://softwarepublico.gov.br/social/articles/0004/5936/Manual_do_Ofertante_Temporario_04.10.2016.pdf>

Further reading material can be found at:
- <http://copyfree.org/policy/copyleft>
- <https://opensource.stackexchange.com/questions/9805/can-i-license-my-project-with-an-open-source-license-but-disallow-commercial-use>
- <https://opensource.stackexchange.com/questions/21/whats-the-difference-between-permissive-and-copyleft-licenses/42#42>

<p align="right">(<a href="#indexerd-md-top">back to top</a>)</p>

# Additional References

- Developed using [VSCode](https://code.visualstudio.com/)
- GUI developed using [PS Winforms Creator](https://www.pswinformscreator.com/)

<p align="right">(<a href="#indexerd-md-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[ermx_overview]: ./docs/img/SMN_overview.svg

