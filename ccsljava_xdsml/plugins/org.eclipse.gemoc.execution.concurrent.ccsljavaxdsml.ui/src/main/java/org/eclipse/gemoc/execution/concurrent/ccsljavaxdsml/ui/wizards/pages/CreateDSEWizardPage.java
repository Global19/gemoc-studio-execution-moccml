/*******************************************************************************
 * Copyright (c) 2017 INRIA and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     INRIA - initial API and implementation
 *******************************************************************************/
package org.eclipse.gemoc.execution.concurrent.ccsljavaxdsml.ui.wizards.pages;

import org.eclipse.gemoc.execution.concurrent.ccsljavaxdsml.ui.wizards.CreateDSEWizardContextAction;
import org.eclipse.gemoc.execution.concurrent.ccsljavaxdsml.ui.wizards.CreateDSEWizardContextAction.CreateDSEAction;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.ui.PlatformUI;

public class CreateDSEWizardPage extends WizardPage {

	
	protected CreateDSEWizardContextAction context;
	
	private Composite 	container;
	
	public CreateDSEWizardPage(String pageName, CreateDSEWizardContextAction context) {
		super(pageName);
		this.setDescription("Select the wizard you wish to use to create a DSE project for your executable language.");
		this.setTitle(pageName);
		this.context = context;
	}
	
	@Override
	public void performHelp(){
		//PlatformUI.getWorkbench().getHelpSystem().displayHelp();
		PlatformUI.getWorkbench().getHelpSystem().displayHelpResource("/org.eclipse.gemoc.language_workbench.documentation/html/DSEProject.html");
	}

	@Override
	public void createControl(Composite parent) {
		
		container = new Composite(parent, SWT.FILL);
		container.setLayout(new RowLayout (SWT.VERTICAL));

		Group actionSelection = new Group(container, SWT.FILL);
		actionSelection.setLayout (new RowLayout (SWT.VERTICAL));
		actionSelection.setText("Select action");
		//actionSelection.setBounds(10, 10, 193, 85);
	    
	    Button createDSAProject = new Button(actionSelection, SWT.RADIO);
	    createDSAProject.setText("Create new DSE project");
	    createDSAProject.setSelection(true);
	    createDSAProject.addListener (SWT.Selection, new Listener () {
			public void handleEvent (Event event) {
				// update context and potentially add new pages ?
				context.actionToExecute = CreateDSEAction.CREATE_NEW_DSE_PROJECT;
			}
		});
	    Button selectExistingDSAProject = new Button(actionSelection, SWT.RADIO);
	    selectExistingDSAProject.setText("Select existing DSE project");  
	    selectExistingDSAProject.addListener (SWT.Selection, new Listener () {
			public void handleEvent (Event event) {
				// update context and potentially add new pages ?
				context.actionToExecute = CreateDSEAction.SELECT_EXISTING_DSE_PROJECT;
			}
		}); 
		
		// Required to avoid an error in the system
		setControl(container);
		setPageComplete(true);
	}
	


}
